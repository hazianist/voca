class TagsController < ApplicationController
  before_action :require_login

  def index
    @search_term = params[:search].to_s.strip
    @sort = params[:sort].presence_in(%w[recent name usage]) || 'recent'
    @usage_filter = params[:usage].presence_in(%w[all active unused]) || 'all'
    @filters_active = @search_term.present? || @sort != 'recent' || @usage_filter != 'all'

    usage_counts_by_tag = current_user.tags.left_outer_joins(:taggings).group('tags.id').count
    @metrics = {
      total_tags: usage_counts_by_tag.length,
      tagged_words: current_user.words.joins(:tags).distinct.count,
      heavy_tags: usage_counts_by_tag.count { |_id, count| count >= Tag::HEAVY_USAGE_THRESHOLD },
      unused_tags: usage_counts_by_tag.count { |_id, count| count.zero? }
    }

    scoped_tags = current_user.tags
                              .left_outer_joins(:taggings)
                              .select('tags.*, COUNT(taggings.id) AS usage_count')
                              .group('tags.id')

    scoped_tags = scoped_tags.where('tags.name LIKE ?', "%#{@search_term}%") if @search_term.present?

    case @usage_filter
    when 'active'
      scoped_tags = scoped_tags.having('COUNT(taggings.id) >= ?', Tag::HEAVY_USAGE_THRESHOLD)
    when 'unused'
      scoped_tags = scoped_tags.having('COUNT(taggings.id) = 0')
    end

    scoped_tags = case @sort
                  when 'name'
                    scoped_tags.order(Arel.sql('LOWER(tags.name) ASC'))
                  when 'usage'
                    scoped_tags.order(Arel.sql('usage_count DESC'))
                  else
                    scoped_tags.order(created_at: :desc)
                  end

    @tags = scoped_tags.page(params[:page]).per(10)

    @top_tags = current_user.tags
                            .left_outer_joins(:taggings)
                            .select('tags.*, COUNT(taggings.id) AS usage_count')
                            .group('tags.id')
                            .order(Arel.sql('usage_count DESC'))
                            .limit(5)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = current_user.tags.build(tag_params)
    if @tag.save
      logger.debug "태그 생성 성공: #{@tag.id}, #{request.format.json?}"
      respond_to do |format|
        format.html { redirect_to tag_path(@tag) }
        format.json { render json: { id: @tag.id, name: @tag.name }, status: :created }
      end
    else
      logger.debug "태그 생성 실패: #{request.format.json?}"
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue => e
    logger.error "태그 생성 중 오류 발생: #{e.message}"
    respond_to do |format|
      format.html { redirect_to new_tag_path, alert: '서버 오류가 발생했습니다.' }
      format.json { render json: { error: '서버 오류가 발생했습니다.' }, status: :internal_server_error }
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update(tag_params)
      redirect_to tags_path
    else
      render :edit
    end
  end

  def destroy
    set_tag
    @tag.destroy
    redirect_to tags_path
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end

  def require_login
    redirect_to login_path unless session[:user_id]
  end
end
