module ApplicationHelper
  def show_logout_link?
    logged_in? && controller_name != "sessions"
  end
end
