class PhotosController < ApplicationController
  before_action :require_login

  def index
    @photos = current_user.photos.order(created_at: :desc)
  end

  def new
    @photo = current_user.photos.new
  end

  def create
    @photo = current_user.photos.new(photo_params)
    if @photo.save
      redirect_to photos_path, notice: "アップロードしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def tweet
    begin
      photo = current_user.photos.find(params[:id])
      token = session[:oauth_access_token]

      return redirect_to(photos_path, alert: "OAuth連携が必要です") if token.blank?
      return redirect_to(photos_path, alert: "画像がありません") unless photo.image.attached?

      image_url = rails_blob_url(photo.image, host: request.base_url)
      TweetClient.new(access_token: token).create_tweet!(
        title: photo.title,
        url: image_url
      )

      redirect_to photos_path, notice: "ツイートしました"
    rescue StandardError => e
      Rails.logger.error("[Tweet] failed: #{e.class} #{e.message}")
      redirect_to photos_path, alert: "ツイートに失敗しました"
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
