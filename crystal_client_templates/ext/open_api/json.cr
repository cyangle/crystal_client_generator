module OpenApi
  module Json
    macro included
      # Builds the object from a JSON::Any hash
      # @param [Hash] JSON::Any
      # @return [Object] Returns the model itself
      def self.build_from_hash(hash : JSON::Any)
        from_json(hash.to_json)
      end

      # Returns the object in the form of hash
      # @return [Hash] Returns the object in the form of hash
      def to_hash : JSON::Any
        JSON.parse(to_json)
      end

      def list_invalid_properties_for(key : String)
        list_invalid_properties.map {|msg| "#{key}: #{msg}"}
      end

      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o : self)
        self == o
      end

      def after_initialize
        raise JSON::ParseException.new("Validation failed", 0, 0) if !valid?
      end
    end
  end
end
