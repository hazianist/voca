class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update]
  skip_before_action :verify_authenticity_token, only: [:update]

  def show
    load_question_data(@question)
    respond_to_format
  end

  def update
    if @question.update(question_params)
      @question.quiz.update_current_question(@question)
      @question.quiz.calculate_score

      next_question = @question.quiz.current_question || @question
      load_question_data(next_question)

      respond_to do |format|
        format.html { redirect_to quiz_path(@question.quiz) }
        format.js {
          render partial: 'questions/question',
                 locals: { question: @question.quiz.current_question, choices: @choices, next_question_id: @next_question_id,
                           previous_question_id: @previous_question_id, question_index: @questions.index(@question.quiz.current_question), total_questions: @questions.size }
        }
      end
    else
      render_show_with_errors
    end
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:user_answer, :answered)
  end

  def load_question_data(current_question)
    @questions = current_question.quiz.questions.order(:question_order)
    @current_question = current_question

    @word = @current_question.word
    @correct_answer = @word.mean
    @wrong_answers = Word.where.not(id: @word.id).order("RANDOM()").limit(3).pluck(:mean)
    @choices = (@wrong_answers + [@correct_answer]).shuffle
    set_navigation_ids(current_question)
  end

  def set_navigation_ids(current_question)
    @previous_question_id = @questions.where('question_order < ?', current_question.question_order).order(:question_order).last&.id
    @next_question_id = @questions.where('question_order > ?', current_question.question_order).order(:question_order).first&.id
  end

  def respond_to_format
    respond_to do |format|
      format.html {
        render partial: 'questions/question',
               locals: { question: @current_question, choices: @choices, next_question_id: @next_question_id,
                         previous_question_id: @previous_question_id, question_index: @questions.index(@current_question), total_questions: @questions.size }
      }
      format.js {
        render partial: 'questions/question',
               locals: { question: @current_question, choices: @choices, next_question_id: @next_question_id,
                         previous_question_id: @previous_question_id, question_index: @questions.index(@current_question), total_questions: @questions.size }
      }
    end
  end

  def render_show_with_errors
    respond_to do |format|
      format.html {
        render partial: 'questions/question',
               locals: { question: @question, choices: @choices, next_question_id: @next_question_id,
                         previous_question_id: @previous_question_id, question_index: @questions.index(@question), total_questions: @questions.size }
      }
      format.js {
        render partial: 'questions/question',
               locals: { question: @question, choices: @choices, next_question_id: @next_question_id,
                         previous_question_id: @previous_question_id, question_index: @questions.index(@question), total_questions: @questions.size }
      }
    end
  end
end
