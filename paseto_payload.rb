require 'paseto'
require 'base64'

# Your Base64-encoded symmetric key (32 bytes when decoded)
base64_key = ""

# Decode the key from Base64
symmetric_key = Base64.decode64(base64_key)

# Ensure the key is 32 bytes
raise ArgumentError, "Symmetric key must be 32 bytes" unless symmetric_key.bytesize == 32

# Initialize the Paseto v4.local instance
paseto = Paseto::V4::Local.new(ikm: symmetric_key)

# The provided token
token = ""

# Decode the token to extract the payload
begin
  result = paseto.decode(token)
  p result
  payload = result.claims
  puts "Decoded payload: #{payload}"
rescue Paseto::ParseError => e
  puts "Failed to parse token: #{e.message}"
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
