module ApplicationHelper
  def nav_active_class(*controller_names)
    controller_names.map(&:to_s).include?(controller_name) ? 'is-active' : ''
  end

  def user_initial_for(user)
    (user&.username.presence || user&.email).to_s.first&.upcase || 'U'
  end

  def display_name_for(user)
    user&.username.presence || user&.email
  end

  def flash_tone_class(key)
    case key.to_sym
    when :notice
      'toast--success'
    when :alert
      'toast--warning'
    when :danger, :error
      'toast--danger'
    else
      'toast--info'
    end
  end

  def locale_switch_url(locale_code)
    path_params = request.path_parameters.symbolize_keys.except(:format, :locale)
    query_params = request.query_parameters.symbolize_keys.except(:locale)
    merged_params = path_params.merge(query_params).merge(locale: locale_code)
    url_for(merged_params)
  rescue ActionController::UrlGenerationError
    url_for(locale: locale_code, controller: controller_name, action: action_name)
  end

  def locale_label(locale_code)
    I18n.t("locales.#{locale_code}")
  end
end
