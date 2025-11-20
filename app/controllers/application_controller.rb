class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :require_sign_in!

  protect_from_forgery with: :exception

  helper_method :current_user, :supported_locales

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out
    session.delete(:user_id)
    @current_user = nil
  end

  def signed_in?
    current_user.present?
  end

  def supported_locales
    I18n.available_locales
  end

  def default_url_options
    options = super || {}
    options = options.except(:locale)
    return options if I18n.locale == I18n.default_locale

    options.merge(locale: I18n.locale)
  end

  private

  def require_sign_in!
    redirect_to login_path unless signed_in?
  end

  def set_locale
    locale = params[:locale]&.to_sym
    locale = session[:preferred_locale]&.to_sym unless supported_locales.include?(locale)
    locale ||= I18n.default_locale

    I18n.locale = supported_locales.include?(locale) ? locale : I18n.default_locale
    session[:preferred_locale] = I18n.locale
  end
end
