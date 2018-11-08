#def current_user
#  if (user_id = session[:user_id])
#    @current_user ||= User.find_by(id: session[:user_id])
#  elsif (user_id = cookies.signed[:user_id])
#    user = User.find_by(id: user_id)
#    if user && user.authenticated?(cookies[:remember_token])
#      log_in user
#      @current_user = user
#    end
#  end
#end
#ここをテスト

require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  #fixtureでuser変数を定義する
  #渡されたユーザーをrememberメソッドで記憶する
  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when sission is nil" do
    #current_userが、渡されたユーザーと同じであることを確認します
    assert_equal @user, current_user
    assert is_logged_in?
  end

  #このテストでは、ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合に
  #現在のユーザーがnilになるかどうかをチェック
  #if user && user.authenticated?(cookies[:remember_token])をチェック
  #rememberダイジェストが不正だった場合はnilを返す
  test "current_user returns nil when remember digest is wrong" do
    #@userに新しいダイジェストをアップデート
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    #current_userは空っぽになっているはず
    assert_nil current_user
  end
end
