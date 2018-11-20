require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  #beforeフィルターは基本的にアクションごとに適用していくので、
  #Usersコントローラのテストもアクションごとに書いていきます。
  #具体的には、正しい種類のHTTPリクエストを使ってeditアクションと
  #updateアクションをそれぞれ実行させてみて、flashにメッセージが代入されたかどうか、ログイン画面にリダイレクトされたかどうかを確認してみましょう。

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: {user: {name: @user.name,email: @user.email}}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params:{user:{password: @other_user.password,password_confirmation:@other_user.password,admin:true}}
    assert_not @other_user.reload.admin?
  end
#ログインしていないユーザーであれば、ログイン画面にリダイレクトされる
  test "should redirect destroy when not loggedin" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

#ログイン済みではあっても管理者でなければ、ホーム画面にリダイレクトされること
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
