ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  #Applicationヘルパーで使っているfull_titleヘルパーを、test環境でも使えるようにする
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  #残念ながらヘルパーメソッドはテストから呼び出せないので、
  #リスト 8.18のようにcurrent_userを呼び出せません。
  #sessionメソッドはテストでも利用できるので、これを代わりに使います。
  #ここでは取り違えを防ぐため、logged_in?の代わりにis_logged_in?を使って、
  #ヘルパーメソッド名がテストヘルパーとSessionヘルパーで同じにならないようにしておきます14。
  def is_logged_in?
    #user_id空ではないですよね？＝ありますよね？＝ログイン中ですよね？
    !session[:user_id].nil?
  end
  #remember_meボックスのテストで使う
  def log_in_as?(user)
    #テストユーザーとしてログインする
    session[:user_id] = user.id
  end

  #統合テストでも同様のヘルパーを実装していきます。
  #ただし統合テストではsessionを直接取り扱うことができないので、
  #代わりにSessionsリソースに対してpostを送信することで代用します
  #メソッド名は単体テストと同じ、log_in_asメソッドとします。
  class ActionDispatch::IntegrationTest
    #テストコードがより便利になるように、
    #log_in_asメソッド (リスト 9.24) ではキーワード引数 (リスト 7.13) のパスワードと
    #[remember me] チェックボックスのデフォルト値を、それぞれ’password’と’1’に設定しています。)
    def log_in_as(user, password: 'password', remember_me: '1')
      post login_path, params: {session: {email: user.email, password: password, remember_me: remember_me}}
    end
  end
end
