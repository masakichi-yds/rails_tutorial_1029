require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    #code
    @user = users(:michael)
  end
  test "unsuccessful edit" do
    #ログインの制限がついたので、エディットのパスの前にログインをしておく必要がある
    log_in_as(@user)
    #編集ページにアクセスし、editビューが描画されるかどうかをチェック
    get edit_user_path(@user)
    assert_template 'users/edit'
    #無効な情報を送信してみて、editビューが再描画されるかどうかをチェック
    #(PATCHリクエストを送るためにpatchメソッドを使っていることに注目)
    patch user_path(@user), params: {user: {name: "",email: "foo@invalid", password: "foo", password_confirmation: "bar"}}
    #renderしているか
    assert_template 'users/edit'
    assert_select 'div.alert-danger', 'The form contains 4 errors'
  end

  test "successful edit" do
    #ログインの制限がついたので、エディットのパスの前にログインをしておく必要がある
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {user:{name: name, email: email, password: "", password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to user_path(@user)
    #データベースから最新のユーザー情報を読み込み直して、正しく更新されたかどうかを確認している
    @user.reload
    #データベース内のユーザー情報が正しく変更されたかどうかも検証します
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
  #リダイレクト先は、ユーザーが開こうとしていたページにしてあげるのが親切というものです。
  test "unsuccessful edit with friendly forwarding" do
    #loginしない状態で編集ページにいきログインを求められた。
    get edit_user_path(@user)
    #ログインする前のURL＝editのURLにパスしているよね
    assert_equal session[:forwarding_url], edit_user_url(@user)
    #ログインし直した
    log_in_as(@user)
    #loginしたあとは先ほどアクセスしようとした場所へ
    assert_redirected_to edit_user_url(@user)
    #session空になってるよね
    assert_nil session[:forwarding_url]
    #あとの動作は一緒
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {user:{name: name, email: email, password: "", password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

end
