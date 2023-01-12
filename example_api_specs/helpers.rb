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
end
