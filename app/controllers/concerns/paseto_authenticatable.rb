require "paseto"
require "base64"

module PasetoAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  # Fetch the secret key from Rails credentials and decode it from Base64
  raw_key = Rails.application.credentials.dig(:paseto, :secret_key)
  PASETO_SECRET_KEY = Base64.decode64(raw_key)

  # Ensure the key is 32 bytes
  raise ArgumentError, "PASETO_SECRET_KEY must be 32 bytes" unless PASETO_SECRET_KEY.bytesize == 32

  SYMMETRIC_KEY = Paseto::V4::Local.new(ikm: PASETO_SECRET_KEY)

  def generate_paseto_token(user)
    payload = {
      user_id: user.id.to_s, # Ensure user_id is a string
      exp: 24.hours.from_now.utc.iso8601 # Ensure exp is a string in ISO 8601 format
    }
    SYMMETRIC_KEY.encode(payload)
  end


  def decode_paseto_token(token)
    begin
      result = SYMMETRIC_KEY.decode(token)
      payload = result.claims

      # Convert the exp back to a Time object for comparison
      expiration_time = Time.parse(payload["exp"])

      # Check for expiration
      if expiration_time < Time.now.utc
        raise "Token has expired"
      end

      User.find(payload["user_id"].to_i) # Convert user_id back to an integer if necessary
    rescue ActiveRecord::RecordNotFound
      nil
    rescue StandardError => e
      Rails.logger.warn "Error processing PASETO token: #{e.message}"
      nil
    end
  end



  def authenticate_user!
    token = request.headers["Authorization"]
    return render json: { error: "Token missing" }, status: :unauthorized unless token

    @current_user = decode_paseto_token(token)
    render json: { error: "Invalid or expired token" }, status: :unauthorized unless @current_user
  end
end
