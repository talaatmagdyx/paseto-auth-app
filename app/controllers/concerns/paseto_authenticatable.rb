require 'paseto'
require 'base64'

module PasetoAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  raw_key = Rails.application.credentials.dig(:paseto, :secret_key)
  raise "PASETO secret key not set in credentials" if raw_key.nil?

  PASETO_SECRET_KEY = Base64.decode64(raw_key)

  raise ArgumentError, "PASETO_SECRET_KEY must be 32 bytes" unless PASETO_SECRET_KEY.bytesize == 32

  SYMMETRIC_KEY = Paseto::V4::Local.new(ikm: PASETO_SECRET_KEY)

  def generate_paseto_token(user)
    payload = {
      user_id: user.id.to_s,
      exp: 24.hours.from_now.utc.iso8601
    }
    SYMMETRIC_KEY.encode(payload)
  end

  def decode_paseto_token(token)
    begin
      result = SYMMETRIC_KEY.decode(token)
      payload = result.claims

      expiration_time = Time.parse(payload['exp'])
      raise "Token has expired" if expiration_time < Time.now.utc

      User.find(payload['user_id'].to_i)
    rescue ActiveRecord::RecordNotFound
      nil
    rescue StandardError => e
      Rails.logger.warn "Error processing PASETO token: #{e.message}"
      nil
    end
  end

  def authenticate_user!
    token = request.headers['Authorization']
    return render json: { error: 'Token missing' }, status: :unauthorized unless token

    @current_user = decode_paseto_token(token)
    render json: { error: 'Invalid or expired token' }, status: :unauthorized unless @current_user
  end
end
