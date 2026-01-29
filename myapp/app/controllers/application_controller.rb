class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # --- application specific settings ---
  helper_method :current_user, :logged_in?, :oauth_configured?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?
    redirect_to new_session_path
  end

  def oauth_configured?
    ENV["OAUTH_AUTHORIZE_URL"].present? &&
      ENV["OAUTH_TOKEN_URL"].present? &&
      ENV["OAUTH_CLIENT_ID"].present? &&
      ENV["OAUTH_CLIENT_SECRET"].present? &&
      ENV["OAUTH_REDIRECT_URI"].present? &&
      ENV["OAUTH_SCOPE"].present? &&
      ENV["TWEET_CREATE_URL"].present?
  end
end
