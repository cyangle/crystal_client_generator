module OpenApi
  class HashValidator
    def self.valid?(hash : Hash) : Bool
      hash.each do |_key, value|
        if value.is_a?(OpenApi::Validatable)
          return false unless value.valid?
        end
      end

      true
    end

    def self.validate(hash : Hash) : Nil
      hash.each do |_key, value|
        if value.is_a?(OpenApi::Validatable)
          value.validate
        end
      end
    end

    def self.list_invalid_properties_for(key : String, hash : Hash) : Array(String)
      hash.each_with_object(Array(String).new) do |(_key, value), invalid_properties|
        if value.is_a?(OpenApi::Validatable)
          invalid_properties.concat(value.list_invalid_properties_for(key))
        end
      end
    end
  end
end
