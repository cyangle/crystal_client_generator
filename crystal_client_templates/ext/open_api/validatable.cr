module OpenApi
  module Validatable
    abstract def valid? : Bool
    abstract def validate : Nil
    abstract def list_invalid_properties : Array(String)
    abstract def list_invalid_properties_for(key : String) : Array(String)
  end
end
