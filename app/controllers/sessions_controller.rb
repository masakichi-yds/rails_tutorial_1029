class SessionsController < ApplicationController
  def new
  end

  def create
    #code
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      #session[:user_id] = user.id
      log_in(user)
      redirect_to user #どういう経緯か？
                        #redirect_to("/users/#{@user.id}")相対パスから絶対パス
                        #redirect_to("https://228e5b796b37495aa0c17e02856dccfa.vfs.cloud9.us-east-2.amazonaws.com/users/#{@user.id}")
                        #redirect_to(user_url(@user.id))絶対パスの変換
                        #redirect_to(user_url(@user))@userは自動的にidにリンク
                        #redirect_to(@user)_urlヘルパーは省略可能
    else
      flash.now[:danger] = "Invalid email/password combination'"
      render 'new'
    end
  end

  def destroy
    #sessions_helperから
    log_out
    redirect_to root_url
  end
end
