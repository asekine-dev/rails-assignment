class SessionsController < ApplicationController
  def new
    @login_form = LoginForm.new
  end

  def create
    form_params = params.require(:login_form).permit(:email, :password)
    @login_form = LoginForm.new(form_params)

    if @login_form.invalid?
      return render :new, status: :unprocessable_entity
    end

    user = User.authenticate_by(
      email: @login_form.normalized_email,
      password: @login_form.password
    )

    if user
      session[:user_id] = user.id
      redirect_to root_path
    else
      @login_form.errors.add(:base, "メールアドレスまたはパスワードが違います")
      render :new, status: :unprocessable_entity
    end
  end
end