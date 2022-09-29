module OpenApi
  class PrimitiveValidator
    MAX_LENGTH_ERROR = "invalid value for \"%s\", the character length must be smaller than or equal to %s."
    MIN_LENGTH_ERROR = "invalid value for \"%s\", the character length must be greater than or equal to %s."
    MIN_NUMBER_ERROR = "invalid value for \"%s\", must be greater than or equal to %s."
    MAX_NUMBER_ERROR = "invalid value for \"%s\", must be smaller than or equal to %s."
    EXCLUSIVE_MIN_NUMBER_ERROR = "invalid value for \"%s\", the character length must be greater than %s."
    EXCLUSIVE_MAX_NUMBER_ERROR = "invalid value for \"%s\", the character length must be smaller than %s."
    MIN_ITEMS_ERROR = "invalid value for \"%s\", number of items must be greater than or equal to %s."
    MAX_ITEMS_ERROR = "invalid value for \"%s\", number of items must be smaller than or equal to %s."
    PATTERN_ERROR = "invalid value for \"%s\", must conform to the pattern %s."

    def self.min_length_error(name : String, length : Int, min : Int) : String?
      return unless length < min
      MIN_LENGTH_ERROR % [name, min.to_s]
    end

    def self.max_length_error(name : String, length : Int, max : Int) : String?
      return unless length > max
      MAX_LENGTH_ERROR % [name, max.to_s]
    end

    def self.min_number_error(name : String, value : Number, min : Number, exclusive : Bool = false) : String?
      if exclusive
        return unless value <= min
        EXCLUSIVE_MIN_NUMBER_ERROR % [name, min.to_s]
      else
        return unless value < min
        MIN_NUMBER_ERROR % [name, min.to_s]
      end
    end

    def self.max_number_error(name : String, value : Number, max : Number, exclusive : Bool = false) : String?
      if exclusive
        return unless value >= max
        EXCLUSIVE_MAX_NUMBER_ERROR % [name, max.to_s]
      else
        return unless value > max
        MAX_NUMBER_ERROR % [name, max.to_s]
      end
    end

    def self.min_items_error(name : String, value : Int, min : Int) : String?
      return unless value < min
      MIN_ITEMS_ERROR % [name, min.to_s]
    end

    def self.max_items_error(name : String, value : Int, max : Int) : String?
      return unless value > max
      MAX_ITEMS_ERROR % [name, max.to_s]
    end

    def self.pattern_error(name : String, value : String, pattern : Regex) : String?
      return if pattern.matches?(value)
      PATTERN_ERROR % [name, pattern.source]
    end
  end
end
