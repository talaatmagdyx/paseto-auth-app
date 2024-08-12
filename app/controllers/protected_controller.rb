class ProtectedController < ApplicationController
  def index
    render json: { message: "Welcome, #{@current_user.name}!" }
  end
end
