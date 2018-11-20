require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do
    #ルートURL (Homeページ) にGETリクエストを送る.
    get root_path
    #正しいページテンプレートが描画されているかどうか確かめる.
    assert_template 'static_pages/home'
    #Home、Help、About、Contactの各ページへのリンクが正しく動くか確かめる.
    assert_select "a[href=?]",root_path, count: 2
    assert_select "a[href=?]",help_path
    assert_select "a[href=?]",about_path
    assert_select "a[href=?]",contact_path
    #assert_select "a[herf=?]",login_path
    #Applicationヘルパーで使っているfull_titleヘルパーを、test環境でも使えるようにする
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
    assert_select "title", full_title("Sign up")
  end

  def setup
    @user = users(:michael)
  end

  test "layout links when logged in" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", users_path
    #assert_select "a[herf=?]",user_path(@user)
    #assert_select "a[herf=?]",edit_user_path(@user)
    #assert_select "a[herf=?]",logout_path
  end
end
