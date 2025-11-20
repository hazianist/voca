class SessionsController < ApplicationController
  skip_before_action :require_sign_in!, only: [:new, :create]
  before_action :set_user, only: [:create]

  def new
    redirect_to main_menu_path if signed_in?
  end

  def create
    password = params.dig(:session, :password)
    if @user&.authenticate(password)
      sign_in(@user)
      redirect_to main_menu_path
    else
      flash.now[:alert] = t('sessions.create.invalid_credentials')
      render :new, status: :unauthorized
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

  private

  def set_user
    email = params.dig(:session, :email).to_s.downcase
    @user = User.find_by(email: email)
  end
end
