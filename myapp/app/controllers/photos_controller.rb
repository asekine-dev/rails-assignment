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

  private

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
