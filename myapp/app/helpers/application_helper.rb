module ApplicationHelper
  def show_logout_link?
    logged_in? && controller_name != "sessions"
  end

  def oauth_connected?
    session[:oauth_access_token].present?
  end
end
