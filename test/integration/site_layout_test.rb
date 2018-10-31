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
    #Applicationヘルパーで使っているfull_titleヘルパーを、test環境でも使えるようにする
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
