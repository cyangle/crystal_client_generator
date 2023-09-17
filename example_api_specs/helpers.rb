require "active_support/all"

class Helpers
  def self.add_tags(spec, regex, mappings = {})
    all_tags = []
    spec["paths"].each do |path, value|
      tag = mappings.fetch(path, nil)
      if tag.nil?
        matches = regex.match(path)
        raise "No match found for path #{path}" if matches.nil?
        # binding.pry if matches.nil?
        tag = matches[1]
      end
      all_tags.push(tag)
      value.each do |_key, operation|
        next unless operation.is_a?(Hash)
        operation["tags"] = [tag]
      end

    end

    spec["tags"] = all_tags.uniq.map {|tag| {"name" => tag}}
  end

  def self.dedupe_schemas(spec_hash)
    schemas_dup = spec_hash["components"]["schemas"].deep_dup
    schemas_dup.each do |k, v|
      v.delete("description")
    end
    duplicate_schemas_keys = schemas_dup
      .group_by { |k,v| v.hash.to_s }
      .select { |k,v| v.count > 1 }
      .map { |k,v| v.map(&:first) }
      .each_with_object({}) do |values, hash|
        groups = values.group_by { |values| values.length }
        new_key = groups[groups.keys.min].sort.first
        new_key = "subresource_uris" if values.include?("subresource_uris")
        hash[new_key] = values.dup.tap do |new_values|
          new_values.delete(new_key)
        end
      end

    duplicate_schemas_keys.each do |key, value|
      value.each do |schema_key|
        schemas_dup.delete(schema_key)
      end
    end

    inverted_duplicate_schemas_keys = duplicate_schemas_keys.each_with_object({}) do |(key,value), hash|
      value.each do |inverted_key|
        hash[inverted_key] = key
      end
    end
    spec_hash["components"]["schemas"] = schemas_dup
    spec_string = spec_hash.to_json

    inverted_duplicate_schemas_keys.each do |key, value|
      spec_string.gsub!("components/schemas/#{key}\"", "components/schemas/#{value}\"")
    end

    JSON.parse(spec_string)
  end
end
