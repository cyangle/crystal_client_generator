class EnumValidator
  getter datatype : String
  getter allowable_values : Set(String | Int32 | Float64)

  def initialize(datatype, allowable_values)
    @datatype = datatype
    @allowable_values = allowable_values.map do |value|
      case datatype.to_s
      when /Integer/i
        value.to_i
      when /Float/i
        value.to_f
      else
        value
      end
    end.to_set
  end

  def valid?(value, allow_nil = true)
    return true if allow_nil && value.nil?

    !value.nil? && allowable_values.includes?(value)
  end

  def all_valid?(values, allow_nil = true)
    return true if allow_nil && values.nil?

    !values.nil? && values.all? { |value| allowable_values.includes?(value) }
  end
end
