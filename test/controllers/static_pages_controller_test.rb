require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  #Homeページのテスト
  test "should get home" do
    #GETリクエストをhomeアクションに対して発行 (=送信) せよ。
    get static_pages_home_url
    #そうすれば、リクエストに対するレスポンスは[成功]になるはず。
    assert_response :success
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
  end

  
end
