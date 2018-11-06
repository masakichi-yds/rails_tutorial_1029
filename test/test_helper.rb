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
end
