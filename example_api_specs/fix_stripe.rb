#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pry"
require "active_support/all"
require "deepsort"

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

spec_path = File.join(__dir__, ARGV[0] || "stripe_v196_spec3.json")
out_file_path = File.join(__dir__, ARGV[1] || "stripe_v196_spec3_fixed.json")
new_schemas_path = File.join(__dir__, ARGV[1] || "stripe_v196_spec3_new_schemas.json")
grouped_schemas_path = File.join(__dir__, ARGV[1] || "stripe_v196_spec3_grouped_schemas.json")
api_endpoints_path = File.join(__dir__, ARGV[1] || "stripe_api_endpoints.txt")

api_endpoints = File.read(api_endpoints_path).split("\n")

spec = JSON.parse(File.read(spec_path))

paths = spec.dig("paths")

paths.each do |path, _value|
  paths.delete(path) unless api_endpoints.include?(path)
end

loose_global_schemas = []
strict_global_schemas = []

def extract_schema(schema, schemas, strict = false)
  if schema.is_a?(Array)
    schema.each do |value|
      extract_schema(value, schemas, strict)
    end
  elsif schema.is_a?(Hash)
    if schema.has_key?("title") && schema["title"].is_a?(String)
      schemas.push(schema.dup) if !strict || (strict && schema.has_key?("description"))
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

duplicated_schemas = uniq_grouped_schemas.select do |_key, array|
  array.size > 1
end

pp duplicated_schemas.keys

new_schemas = grouped_schemas
  .each_with_object({}) {|(key, value), obj| obj[key] = value.each_with_object({}) {|value2, obj2| obj2.deep_merge!(value2)}}

new_schemas.delete("param")

puts new_schemas.keys.size

spec_schemas = new_schemas.merge(spec["components"]["schemas"])

schema_dict = spec_schemas.each_with_object({}) do |(key, schema), obj|
  properties = []
  properties = schema["properties"].keys if schema["properties"] && schema["properties"].is_a?(Hash)
  obj[key] = properties
end

def find_schema_name(schema, schema_dict)
  return unless schema.is_a?(Hash)
  title = schema["title"].to_s.underscore
  schema_name = schema_dict.find do |key, value|
    key == title
  end&.first

  property_set = (schema["properties"] || []).to_set
  return schema_name if IGNORED_PROPERTY_LIST.any? { |ipl| ipl == property_set }
  return schema_name unless schema_name.nil? && schema["type"] == "object" && schema["properties"] && schema["properties"].keys.size > 1

  property_names = schema["properties"].keys
  schema_name ||= schema_dict.find do |key, value|
    value == property_names
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

spec_schemas.each do |key, schema|
  schema.each do |_key, value|
    update_schema_with_ref(value, schema_dict)
  end
end

update_schema_with_ref(paths, schema_dict)

spec["components"]["schemas"] = spec_schemas
spec["paths"].each do |path, value|
  next unless value.has_key?("get")
  value["get"].delete("requestBody") if value["get"] && value["get"].is_a?(Hash) && value.dig("get", "requestBody", "content", "application/x-www-form-urlencoded", "schema", "properties").empty?
  value["delete"].delete("requestBody") if value["delete"] && value["delete"].is_a?(Hash) && value.dig("delete", "requestBody", "content", "application/x-www-form-urlencoded", "schema", "properties").empty?
end

File.write(grouped_schemas_path, JSON.pretty_generate(uniq_grouped_schemas.deep_sort))
File.write(new_schemas_path, JSON.pretty_generate(new_schemas.deep_sort))

spec_str = JSON.pretty_generate(spec)

File.write(out_file_path, JSON.pretty_generate(JSON.parse(spec_str).deep_sort))
