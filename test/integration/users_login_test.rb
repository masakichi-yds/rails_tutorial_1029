require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    #fixtureのusers.ymlのキーmichaelとして代入し利用
    @user = users(:michael)
  end
  test "login with invalid information" do
    #ログイン用のパスを開く
    get login_path
    #新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    #わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: {session: {email: "",password: ""}}
    #新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    #別のページ (Homeページなど) にいったん移動する
    get root_path
    #移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end

  test "login with valid information followed by logout_path" do

    #ログイン用のパスを開く
    get login_path
    #セッション用パスに有効な情報をpostする
    post login_path, params: {session: {email: @user.email,password: "password"}}
    #test_helperよりログインしてますよね？
    assert is_logged_in?
    #リダイレクト先が正しいかどうかをチェックしています
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    #ログイン用リンクが表示されなくなったことを確認する
    assert_select "a[herf=?]", login_path, count:0
    #ログアウト用リンクが表示されていることを確認する
    assert_select "a[href=?]", logout_path
    #プロフィール用リンクが表示されていることを確認する
    assert_select "a[href=?]", user_path(@user)

    #logoutにパスする
    delete logout_path
    #ログイン情報(session[:user_id])消えたよね（not）？
    assert_not is_logged_in?
    #リダイレクト先が正しいか
    assert_redirected_to root_url

    #２番目のウィンドウでログアウトをクリックするユーザーをシミュレート
    #current_userがないために2回目のdelete logout_pathの呼び出しでエラー
    delete logout_path
    #Deleteリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    #ログイン用リンクが表示されたことを確認する
    assert_select "a[href=?]", login_path
    #ログアウト用リンクが表示されていないことを確認する
    assert_select "a[href=?]", logout_path,      count: 0
    #プロフィール用リンクが表示されていることを確認する
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    #クッキーを保存して（チェックボックスありで）ログイン
    log_in_as(@user, remember_me:'1')
    #remember_token空ではない
    assert_equal cookies['remember_token'],assigns(:user).remember_token
  end

  test "login without remembering" do
    #クッキーを保存して（チェックボックスありで）ログイン
    log_in_as(@user,remember_me:'1')
    #ログアウトする
    delete logout_path
    #クッキーを削除して（チェックボックスなしで）ログイン
    log_in_as(@user,remember_me: '0')
    #rememeberトークンは空
    assert_empty cookies['remember_token']
  end
end
