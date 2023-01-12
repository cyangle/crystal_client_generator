#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pry"
require "pry-byebug"
require "active_support/all"
require "deepsort"
require_relative "./helpers"

MISSING_SCHEMAS = {}.freeze

ADDITIONAL_PROPERTIES = {
  type: "string",
  nullable: true
}.freeze

DEFAULT_PROPERTIES = {
  additionalProperties: {
    type: "string",
    nullable: true
  },
  nullable: true,
  type: "object"
}.freeze

DEFAULT_PROPERTY_NAMES = %w[
  sip
  sip.sip_domain.sip_auth
  sip.sip_domain.sip_auth.sip_auth_calls
  sip.sip_domain.sip_auth.sip_auth_registrations
  usage
].freeze

IGNORED_PROPERTY_LIST = [
  ["data", "has_more", "object", "url"].to_set
]

TAG_REGEX = /^\/v1\/([^\/]+)/.freeze

FREE_FORM_MAP_KEYS = ["additionalProperties", "type", "nullable"].freeze

spec_path = File.join(__dir__, ARGV[0] || "stripe_api_spec.json")
out_file_path = File.join(__dir__, ARGV[1] || "stripe_api_spec_fixed.json")
new_schemas_path = File.join(__dir__, ARGV[1] || "stripe_api_spec_new_schemas.json")
free_form_schemas_path = File.join(__dir__, ARGV[1] || "stripe_api_spec_free_form_schemas.json")
grouped_schemas_path = File.join(__dir__, ARGV[1] || "stripe_api_spec_grouped_schemas.json")
api_endpoints_path = File.join(__dir__, ARGV[1] || "stripe_api_endpoints.txt")

api_endpoints = File.read(api_endpoints_path).split("\n")

spec = JSON.parse(File.read(spec_path))

extra_free_form_schemas = JSON.parse(File.read("stripe_api_spec_free_form_schemas_all.json"))

paths = spec.dig("paths")

paths.each do |path, _value|
  paths.delete(path) unless api_endpoints.include?(path)
end

loose_global_schemas = []
strict_global_schemas = []
GLOBAL_FREE_FORM_SCHEMAS = []

def extract_schema(schema, schemas, strict = false)
  if schema.is_a?(Array)
    schema.each do |value|
      extract_schema(value, schemas, strict)
    end
  elsif schema.is_a?(Hash)
    if schema.has_key?("title") && schema["title"].is_a?(String)
      schemas.push(schema.deep_dup) if !strict || (strict && schema.has_key?("description"))
    end
    if schema.has_key?("additionalProperties") && schema["additionalProperties"].is_a?(Hash)
      puts "free form schema has key properties or title: #{schema}" if schema.has_key?("properties") || schema.has_key?("title")
      GLOBAL_FREE_FORM_SCHEMAS.push(schema.deep_dup.slice(*FREE_FORM_MAP_KEYS))
    end
    schema.each do |_key, value|
      extract_schema(value, schemas, strict)
    end
  end
end

def fill_schemas(paths, schemas, strict=false)
  paths.each do |path_key, path_value|
    path_value.each do |action_key, action_value|
      # schema = action_value.dig("requestBody", "content", "application/x-www-form-urlencoded", "schema")
      extract_schema(action_value, schemas, strict)
    end
  end
end

spec["components"]["schemas"].each do |key, value|
  extract_schema(value["properties"], loose_global_schemas)
  extract_schema(value["properties"], strict_global_schemas, true)
end

fill_schemas(paths, loose_global_schemas)
fill_schemas(paths, strict_global_schemas, true)

def group_schema(schemas)
  schemas
    .map {|schema| schema.delete("description"); schema}
    .uniq
    .group_by {|schema| schema["title"].underscore }
end

loose_grouped_schemas = group_schema(loose_global_schemas)
strict_grouped_schemas = group_schema(strict_global_schemas)
grouped_schemas = loose_grouped_schemas.merge(strict_grouped_schemas)

uniq_grouped_schemas = grouped_schemas.each_with_object({}) do |(key, array), obj|
  array2 = array.map {|e| e.delete("description"); e}.uniq
  if array2.size > 1
    element = array2.find do |elm|
      array2.all? do |value|
        value["properties"] && elm["properties"] && (value["properties"].keys - elm["properties"].keys).empty?
      end
    end
    array2 = [element] if element
  end
  obj[key] = array2
end

deep_duplicated_schemas = uniq_grouped_schemas.select do |_key, array|
  array.size > 1
end

pp deep_duplicated_schemas.keys

new_schemas = grouped_schemas
  .each_with_object({}) {|(key, value), obj| obj[key] = value.each_with_object({}) {|value2, obj2| obj2.deep_merge!(value2)}}
  .merge(extra_free_form_schemas)

new_schemas.delete("param")

puts new_schemas.keys.size

spec_schemas = new_schemas.merge(spec["components"]["schemas"])

def build_schema_dict(spec_schemas)
  spec_schemas.each_with_object({}) do |(key, schema), obj|
    info = {
      "properties" => [],
      "schema" => schema.deep_dup
    }
    info["properties"] = schema["properties"].keys.to_set if schema["properties"] && schema["properties"].is_a?(Hash)
    obj[key] = info
  end
end

def find_schema_name(schema, schema_dict)
  return unless schema.is_a?(Hash)
  title = schema["title"].to_s.underscore
  schema_name = schema_dict.find do |key, value|
    key == title
  end&.first

  return schema_name if schema_name

  if schema.has_key?("additionalProperties") && !schema.has_key?("properties")
    free_form_schema = schema.deep_dup.slice(*FREE_FORM_MAP_KEYS)
    schema_name = schema_dict.find do |key, value|
      free_form_schema == value["schema"]
    end&.first
    return schema_name if schema_name
  end

  property_set = (schema["properties"]&.keys || []).to_set
  return schema_name if IGNORED_PROPERTY_LIST.any? { |ipl| ipl == property_set }
  return schema_name unless schema_name.nil? && schema["type"] == "object" && schema["properties"] && schema["properties"].keys.size > 1

  schema_name ||= schema_dict.find do |key, value|
    value["properties"] == property_set
  end&.first

  schema_name
end

def update_schema_with_ref(schema, schema_dict)
  if schema.is_a?(Array)
    schema.each do |value|
      update_schema_with_ref(value, schema_dict)
    end
  elsif schema.is_a?(Hash)
    if schema_name = find_schema_name(schema, schema_dict)
      schema.clear
      schema["$ref"] = "#/components/schemas/#{schema_name}"
    else
      schema.each do |_key, value|
        update_schema_with_ref(value, schema_dict)
      end
    end
  end
end

def update_spec_schemas_with_ref(spec_schemas, schema_dict)
  spec_schemas.each do |key, schema|
    schema.each do |_key, value|
      update_schema_with_ref(value, schema_dict)
    end
  end
end

def loop_update_spec_schemas(spec_schemas)
  loop do
    deep_dup = spec_schemas.deep_dup
    schema_dict = build_schema_dict(spec_schemas)
    update_spec_schemas_with_ref(spec_schemas, schema_dict)
    break if deep_dup == spec_schemas
  end
end

loop_update_spec_schemas(spec_schemas)

def loop_update_paths(paths, spec_schemas)
  schema_dict = build_schema_dict(spec_schemas)
  loop do
    deep_dup = paths.deep_dup
    update_schema_with_ref(paths, schema_dict)
    break if deep_dup == paths
  end
end

loop_update_paths(paths, spec_schemas)

spec["components"]["schemas"] = spec_schemas

# Delete empty request bodies
spec["paths"].each do |path, value|
  next unless value.has_key?("get") || value.has_key?("delete")
  value["get"].delete("requestBody") if value["get"] && value["get"].is_a?(Hash) && value.dig("get", "requestBody", "content", "application/x-www-form-urlencoded", "schema", "properties").empty?
  value["delete"].delete("requestBody") if value["delete"] && value["delete"].is_a?(Hash) && value.dig("delete", "requestBody", "content", "application/x-www-form-urlencoded", "schema", "properties").empty?
end

Helpers.add_tags(spec, TAG_REGEX)

File.write(grouped_schemas_path, JSON.pretty_generate(uniq_grouped_schemas.deep_sort))
File.write(new_schemas_path, JSON.pretty_generate(new_schemas.deep_sort))
File.write(free_form_schemas_path, JSON.pretty_generate(GLOBAL_FREE_FORM_SCHEMAS.deep_sort.uniq))

spec_str = JSON.pretty_generate(spec)

File.write(out_file_path, JSON.pretty_generate(JSON.parse(spec_str).deep_sort))
