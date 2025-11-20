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
end
