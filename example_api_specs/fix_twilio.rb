#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pry"
require "pry-byebug"
require "active_support/all"
require_relative "./helpers"

ADDITIONAL_PROPERTIES = {
  type: "string",
  nullable: true
}.freeze


BAD_PATHS = [
  "/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}/Siprec.json",
  "/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}/Streams.json"
].freeze

DEFAULT_PROPERTIES = {
  additionalProperties: {
    type: "string",
    nullable: true
  },
  nullable: true,
  type: "object"
}.freeze

MISSING_SCHEMAS = {
  subresource_uris: {
    description: "Account Instance Subresources",
    additionalProperties: {
      type: "string",
      nullable: true
    },
    nullable: true,
    type: "object"
  },
  encryption_details: {
    description: "Call recording encryption details",
    properties: {
      type: {
        type: "string",
        nullable: true
      },
      public_key_sid: {
        type: "string",
        nullable: true
      },
      encrypted_cek: {
        type: "string",
        nullable: true
      },
      iv: {
        type: "string",
        nullable: true
      }
    },
    nullable: true,
    type: "object"
  },
  http_method: {
    "type": "string",
    "format": "http-method",
    "enum": [
      "HEAD",
      "GET",
      "POST",
      "PATCH",
      "PUT",
      "DELETE"
    ],
    "nullable": true,
    "description": "HTTP method used with the request url"
  }
}.freeze

DEFAULT_PROPERTY_NAMES = %w[
  sip
  sip.sip_domain.sip_auth
  sip.sip_domain.sip_auth.sip_auth_calls
  sip.sip_domain.sip_auth.sip_auth_registrations
  usage
].freeze

CAPABILITIES = {
  description: "Indicate if a phone can receive calls or messages",
  nullable: true,
  properties: {
    fax: {
      type: "boolean"
    },
    mms: {
      type: "boolean"
    },
    sms: {
      type: "boolean"
    },
    voice: {
      type: "boolean"
    }
  },
  type: "object"
}.freeze

TRUNK_SID = {
  maxLength: 34,
  minLength: 0,
  nullable: true,
  pattern: "^TK[0-9a-fA-F]{32}$|^$",
  type: "string"
}.freeze

CALL_EVENT = {
  properties: {
    request: {
      description: "Call Request.",
      nullable: true,
      properties: {
        method: {
          type: "string",
          nullable: true
        },
        url: {
          type: "string",
          nullable: true
        },
        parameters: {
          type: "object",
          additionalProperties: {
            type: "string",
            nullable: true
          }
        }
      },
      type: "object"
    },
    response: {
      description: "Call Response with Events.",
      nullable: true,
      properties: {
        response_code: {
          type: "integer",
          nullable: true
        },
        request_duration: {
          type: "integer",
          nullable: true
        },
        content_type: {
          type: "string",
          nullable: true
        },
        date_created: {
          type: "string",
          nullable: true
        },
        response_body: {
          type: "string"
        }
      },
      type: "object"
    }
  },
  type: "object"
}.freeze

HTTP_METHOD = {
  "$ref": "#/components/schemas/http_method"
}
# /2010-04-01/Accounts/
TAG_REGEX = /^\/2010-04-01\/Accounts\/{AccountSid}\/([^\/\.]+)/.freeze
TAG_MAPPING = {
  "/2010-04-01/Accounts.json" => "Accounts",
  "/2010-04-01/Accounts/{Sid}.json" => "SubAccounts"
}

spec_path = File.join(__dir__, ARGV[0] || "twilio_api_v2010.json")
out_file_path = File.join(__dir__, ARGV[1] || "twilio_api_v2010_fixed.json")

def fix_properties(new_name, value)
  return DEFAULT_PROPERTIES.dup if DEFAULT_PROPERTY_NAMES.include?(new_name)

  if new_name == "incoming_phone_number.incoming_phone_number_assigned_add_on"
    value["properties"]["configuration"]["additionalProperties"] = ADDITIONAL_PROPERTIES
  end
  value["properties"]["price"]["type"] = "string" if value.dig("properties", "price", "type")
  value["properties"]["issues"]["items"]["type"] = "string" if new_name == "call.call_feedback_summary"
  value["properties"]["capabilities"] = CAPABILITIES.dup if new_name == "address.dependent_phone_number"

  return CALL_EVENT.dup if new_name == "call.call_event"

  if (trunk_sid = value.dig("properties", "trunk_sid"))
    value["properties"]["trunk_sid"] = TRUNK_SID.dup.merge!(description: trunk_sid["description"])
  end
  if (encryption_details = value.dig("properties", "encryption_details"))
    value["properties"]["encryption_details"] = {
      "$ref" => "#/components/schemas/encryption_details",
      "description" => encryption_details["description"]
    }
  end
  if (subresource_uris = value.dig("properties", "subresource_uris"))
    value["properties"]["subresource_uris"] = {
      "$ref" => "#/components/schemas/subresource_uris",
      "description" => subresource_uris["description"]
    }
  end
  value
end

spec = JSON.parse(File.read(spec_path))

schemas = spec.dig("components", "schemas")
new_schemas = {}

schemas.each do |name, value|
  new_name = name.sub("api.v2010.account.", "")
  new_name = "account" if name == "api.v2010.account"
  new_schemas[new_name] = fix_properties(new_name, value.dup)
end

spec["components"]["schemas"] = new_schemas.merge!(MISSING_SCHEMAS.dup)
request_body = spec["paths"]["/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}/Payments.json"]["post"]["requestBody"]
request_body["content"]["application/x-www-form-urlencoded"]["schema"]["properties"]["Parameter"]["type"] = "string"

BAD_PATHS.each do |path_name|
  spec["paths"].delete(path_name)
end

def process_hash(value)
  return unless value.is_a?(Hash)
  if value["format"] == "http-method"
    value.clear
    value["$ref"] = "#/components/schemas/http_method"
    return
  end
  value.each do |_key, value2|
    process_hash(value2)
  end
end

process_hash(spec)

spec_str = JSON.pretty_generate(spec)
spec_str
  .gsub!("date-time-rfc-2822", "date-time")
  .gsub!("#/components/schemas/api.v2010.account.", "#/components/schemas/")
  .gsub!("#/components/schemas/api.v2010.account", "#/components/schemas/account")
  .gsub!("\"previous_page_uri\": {", "\"previous_page_uri\": {\n\"nullable\": true,")
  .gsub!("\"next_page_uri\": {", "\"next_page_uri\": {\n\"nullable\": true,")

spec = JSON.parse(spec_str)

3.times do
  spec = Helpers.dedupe_schemas(spec)
end

Helpers.add_tags(spec, TAG_REGEX, TAG_MAPPING)

spec_str = JSON.pretty_generate(spec)

File.write(out_file_path, JSON.pretty_generate(JSON.parse(spec_str)))
