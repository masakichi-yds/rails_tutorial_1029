require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    #routes /signup
    get signup_path
    #invalid post すると引数であるUser.countユーザー数は変わらないよね。
    #だって登録されてないから
    assert_no_difference 'User.count' do
      post signup_path, params: {user: {name: "",
                            email: "user@invalid",
                            password: "foo",
                            password_confirmation: "bar"}}
    end
    #users/newアクションにリダイレクト
    assert_template 'users/new'
    #実装したエラーメッセージに対するテスト
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'form[action="/signup"]'
  end

  test "valid signup information" do
    #sinup画面に移動
    get signup_path
    #引数'User.count'がブロック内の処理をすると１つ増える
    #postして、無事登録されカウントが１つ増える
    assert_difference 'User.count', 1 do
      post users_path, params: {user: {name: "Example User",
                          email: "user@example.com",
                          password: "password",
                          password_confirmation: "password"}}
    end
    #無事保存さえたらredirect
    follow_redirect!
    #usersのshowのviewが表示
    assert_template 'users/show'
    #その時にflashが空ではないですよね？
    assert_not flash.empty?
  end
end
