# frozen_string_literal: true
class UsersController < ApplicationController
  skip_before_action :require_sign_in!, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)
      redirect_to main_menu_path, notice: t('users.create.success')
    else
      flash.now[:alert] = t('users.create.failure')
      render :new, status: :unprocessable_entity
    end
  end


  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :highest_rate)
  end
end
