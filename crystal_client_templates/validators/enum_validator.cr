module OpenApi
  class EnumValidator
    ERROR_MESSAGE = "invalid value for \"%s\", must be one of %s."

    def self.error_message(name : String, allowable_values : StaticArray(T, N)) : String forall T
      ERROR_MESSAGE % [name, allowable_values.to_s]
    end

    def self.valid?(name : String, value : T?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Bool forall T
      return true if allow_nil && value.nil?

      !value.nil? && allowable_values.includes?(value.not_nil!)
    end

    def self.valid?(name : String, values : Array(T)?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Bool forall T
      return true if allow_nil && values.nil?

      !values.nil? && values.not_nil!.all? { |value| allowable_values.includes?(value) }
    end

    def self.valid?(name : String, hash : Hash(U, T)?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Bool forall T, U
      return true if allow_nil && hash.nil?

      !hash.nil? && hash.not_nil!.all? { |(_key, value)| allowable_values.includes?(value) }
    end

    def self.validate(name : String, value : T?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Nil forall T
      raise ArgumentError.new(ERROR_MESSAGE % [name, allowable_values.to_s]) unless valid?(name, value, allowable_values, allow_nil)
    end

    def self.validate(name : String, values : Array(T)?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Nil forall T
      raise ArgumentError.new(ERROR_MESSAGE % [name, allowable_values.to_s]) unless valid?(name, values, allowable_values, allow_nil)
    end

    def self.validate(name : String, hash : Hash(U, T)?, allowable_values : StaticArray(T, N), allow_nil : Bool = true) : Nil forall T, U
      raise ArgumentError.new(ERROR_MESSAGE % [name, allowable_values.to_s]) unless valid?(name, hash, allowable_values, allow_nil)
    end
  end
end
