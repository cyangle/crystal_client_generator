module OpenApi
  class ArrayValidator
    def self.valid?(array : Array) : Bool
      array.each do |item|
        if item.is_a?(OpenApi::Validatable)
          return false unless item.valid?
        end
      end

      true
    end

    def self.validate(array : Array) : Nil
      array.each do |item|
        if item.is_a?(OpenApi::Validatable)
          item.validate
        end
      end
    end

    def self.list_invalid_properties_for(key : String, array : Array) : Array(String)
      array.each_with_object(Array(String).new) do |item, invalid_properties|
        if item.is_a?(OpenApi::Validatable)
          invalid_properties.concat(item.list_invalid_properties_for(key))
        end
      end
    end
  end
end
