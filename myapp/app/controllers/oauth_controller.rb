class OauthController < ApplicationController
  before_action :require_login

  def authorize
    unless oauth_configured?
      redirect_to photos_path, alert: "OAuth連携の設定が未完了です"
      return
    end

    redirect_to Oauth::AuthorizationUrl.new.to_s, allow_other_host: true
  end

  def callback
    begin
      return redirect_to(photos_path, alert: "OAuth連携の設定が未完了です") unless oauth_configured?

      code = params[:code].to_s
      return redirect_to(photos_path, alert: "認可コードが取得できませんでした") if code.blank?

      token = Oauth::TokenClient.new.exchange_code_for_token!(code:)
      session[:oauth_access_token] = token
      redirect_to photos_path, notice: "OAuth連携しました"
    rescue => e
      Rails.logger.error("[OAuth] callback failed: #{e.class} #{e.message}")
      redirect_to photos_path, alert: "OAuth連携に失敗しました"
    end
  end
end
