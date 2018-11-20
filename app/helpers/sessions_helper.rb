module SessionsHelper
  def log_in(user)
    #渡されたユーザーでログインする
    #sessionメソッドで作成した一時cookiesは自動的に暗号化
    session[:user_id] = user.id
  end

  #ユーザーのセッションを永続的にする
  def remember(user)
    #code
    user.remember
    cookies[:user_id] = user.id
    #しかしこのままではIDが生のテキストとしてcookiesに保存されてしまうので、
    #アプリケーションのcookiesの形式が見え見えになってしまい、
    #攻撃者がユーザーアカウントを奪い取ることを助けてしまう可能性があります。
    #これを避けるために、署名付きcookieを使います。
    #これは、cookieをブラウザに保存する前に安全に暗号化するためのものです8。
    #ユーザーIDと記憶トークンはペアで扱う必要があるので、cookieも永続化しなくてはなりません。
    #そこで、次のようにsignedとpermanentをメソッドチェーンで繋いで使います。
    cookies.permanent.signed[:user_id] = user.id
    #個別のcookiesは、１つのvalue (値) と、オプションのexpires (有効期限) からできています。
    #有効期限は省略可能です。例えば次のように、20年後に期限切れになる
    #記憶トークンと同じ値をcookieに保存することで、永続的なセッションを作ることができます。
    #cookies[:remember_token] = { value:   remember_token,expires: 20.years.from_now.utc }
    #上のように20年で期限切れになるcookies設定はよく使われるようになり、
    #今ではRailsにも特殊なpermanentという専用のメソッドが追加されたほどです。
    #このメソッドを使うと、コードは次のようにシンプルになります。
    cookies.permanent[:remember_token] = user.remember_token
  end

  #渡されたユーザ＾がログイン済みのユーザーであればtrue
  def current_user?(user)
    user == current_user
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
    if (user_id = session[:user_id])
      #==ではないから代入だよ
      #session[:user_id]があるなら以下を実行
      #上の短縮形
      #@current_user ||= User.find_by(id: session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    #もしcookieを持っていたなら、クッキーのユーザーidを代入
    elsif (user_id = cookies.signed[:user_id])
      #そのcookieからユーザーidを見つけ出す
      user = User.find_by(id: user_id)
      #存在していて、cookieの記憶トークンとデータの記憶トークン（diges）が一緒なら
      if user && user.authenticated?(cookies[:remember_token])
        #ログインしましょ
        log_in user
        #カレントユーザーを代入しましょ
        @current_user = user
      end
    end
  end

  def logged_in?
    #current_userがnilでない（！）(＝ログインしていれば)=true,そのほかならfalse
    !current_user.nil?
  end

  #永続セッションを破棄する
  def forget(user)
    #modelのforgetメソッド
    #update_attribute(remember_digest,nil)
    user.forget
    #cookieのuser_id,remember_tokenも破棄
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    #上のメソッドをcurrent_user（ログイン中のユーザー）で実行
    forget(current_user)
    #session[usr_id] = nil
    session.delete(:user_id)
    @current_user = nil
  end

  #ユーザーを希望のページに転送するには、
  #リクエスト時点のページをどこかに保存しておき、
  #その場所にリダイレクトさせる必要があります。
  #この動作をstore_locationとredirect_back_orの2つのメソッドを使って実現してみましょう。

  #記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    #sessionにリダイレクト先のURLが入っているかどうか、入ってないならデフォルトのURL先に
    redirect_to(session[:forwarding_url] || default)
    #一回使ったら無かったことにする
    #転送用のURLを削除している点にも注意してください。
    #これをやっておかないと、次回ログインしたときに保護されたページに転送されてしまい
    #、ブラウザを閉じるまでこれが繰り返されてしまいます
    session.delete(:forwarding_url)
  end
  #上のsessionに入っているURL先はどこでセットするか
  #アクセスしようとしたURLを覚えておく
  def store_location
    #request.original_urlでリクエスト先が取得できます
    #リクエストを送ってきたユーザのヘッダー情報や環境変数を取得する
    #リクエストが送られたURLをsession変数の:forwarding_urlキーに格納しています。
    #ただし、GETリクエストが送られたときだけ格納するようにしておきます。
    #これによって、例えばログインしていないユーザーがフォームを使って送信した場合、
    #転送先のURLを保存させないようにできます。
    session[:forwarding_url] = request.original_url if request.get?
  end
end
