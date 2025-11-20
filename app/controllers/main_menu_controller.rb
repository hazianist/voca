class MainMenuController < ApplicationController
  before_action :require_login

  def index
    @word_count = current_user.words.count
    @tag_count = current_user.tags.count
    @quiz_count = current_user.quizzes.count
    @accuracy = current_user.correct_rate.to_f

    @recent_quizzes = current_user.quizzes.order(created_at: :desc).limit(3)

    @top_tags = current_user.tags
                           .left_outer_joins(:taggings)
                           .select('tags.*, COUNT(taggings.id) AS usage_count')
                           .group('tags.id')
                           .order(Arel.sql('usage_count DESC'))
                           .limit(3)
  end

  def home

  end

  def require_login
    redirect_to login_path unless session[:user_id]
  end

end
