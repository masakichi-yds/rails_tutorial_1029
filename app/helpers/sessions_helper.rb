module SessionsHelper
  def log_in(user)
    #渡されたユーザーでログインする
    #sessionメソッドで作成した一時cookiesは自動的に暗号化
    session[:user_id] = user.id
  end

  def current_user
    #if @current_user.nil?
    #   @current_user = User.find_by(id: session[:user_id])
    # else
    #   @ current_user
    # end
    #これを簡単にor演算子でかくと以下になる
    #@current_user = @current_user || User.find_by(id: session[:user_id])
    #トドのつまり、@current_userがnilまたはfalseならば右辺を代入するとなる
    #Userオブジェクトそのものの論理値は常にtrueになることです。
    #そのおかげで、@current_userに何も代入されていないときだけfind_by呼び出しが実行され、無駄なデータベースへの読み出しが行われなくなります。
    if session[:user_id]
      #session[:user_id]があるなら以下を実行
      #上の短縮形
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    #current_userがnilでない（！）(＝ログインしていれば)=true,そのほかならfalse
    !current_user.nil?
  end

  def log_out
    #session[usr_id] = nil
    session.delete(:user_id)
    @current_user = nil
  end
end
