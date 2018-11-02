require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    #Userを設定、各メソッド呼び出しで使えるようにする
    @user = User.new(name: "Example User",email: "user@example.com",
                      password: "foobar",password_confirmation: "foobar")
  end

  test "should be valid" do
    #シンプルなassertメソッドを使ってテストします。@user.valid?がtrueを返すと成功し、falseを返すと失敗します。
    assert @user.valid?
  end

  test "name should be present" do
    #空のユーザーname入れたけど
    @user.name = ""
    #それだと有効、ではないよね(not)？
    assert_not @user.valid?
  end

  test "email should be present" do
    #空のユーザーemail入れたけど
    @user.email = ""
    #それだとuserは有効、ではないよね(not)？
    assert_not @user.valid?
  end

  test "name should not be too long" do
    #ユーザーname50字以上だけど
    @user.name = "a" * 51
    #それだと有効、ではないよね(not)？
    assert_not @user.valid?
  end

  test "email should not be too long" do
    #ユーザーemail244字で入れたけど
    @user.email = "a" * 244 + "@example.com"
    #それだとuserは有効、ではないよね(not)？
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    #文字列の配列を簡単に作れる%w[]という便利なテクニック
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    #ループさせずにテストすると、失敗した行番号とメールアドレスの行数を照らし合わせて、
    #失敗したメールアドレスを特定するといった作業が発生してしまいます。
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      #assertメソッドの第2引数にエラーメッセージを追加していることに注目してください。
      #これによって、どのメールアドレスでテストが失敗したのかを特定できるようになります。
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should rejuct invalid addresses" do
    #文字列の配列を簡単に作れる%w[]という便利なテクニック
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    #ループさせずにテストすると、失敗した行番号とメールアドレスの行数を照らし合わせて、
    #失敗したメールアドレスを特定するといった作業が発生してしまいます。
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      #assertメソッドの第2引数にエラーメッセージを追加していることに注目してください。
      #これによって、どのメールアドレスでテストが失敗したのかを特定できるようになります。
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    #dupは、同じ属性を持つデータを複製するためのメソッドです。
    #@userを保存した後では、複製されたユーザーのメールアドレスが既にデータベース内に存在するため、
    #ユーザの作成は無効になるはずです。
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    #無効になるはず
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowaer-case" do
    #大文字のemailを入れてみる。
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    #データベースの値に合わせて更新するreloadメソッドと、
    #値が一致しているかどうか確認するassert_equalメソッドを使っています。
    #reload= setupの所のnewメソッドやっている？
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present(nonblank)" do
    #パスワードが空でないことと最小文字数 (6文字)
    #パスワードとパスワード確認に対して同時に代入をしています (多重代入)
    @user.password = @user.password_confirmation = ""*6
    #空（最小６文字）なので、無効ですよね？
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    #最小文字数が６文字以上に設定
    #５文字のパスワードにした
    @user.password = @user.password_confirmation = "a"*5
    #５文字だから無効ですよね？
    assert_not @user.valid?
  end
end
