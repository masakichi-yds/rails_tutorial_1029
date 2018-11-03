class UsersController < ApplicationController
  def new
    #form_forの引数で必要となるUserオブジェクトを作成する
    @user = User.new
  end

  def show
    #params[:id]は文字列型の "1" ですが、findメソッドでは自動的に整数型に変換されます
    @user = User.find(params[:id])
  end

  def create
    #code
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user #どういう経緯か？
                        #redirect_to("/users/#{@user.id}")相対パスから絶対パス
                        #redirect_to("https://228e5b796b37495aa0c17e02856dccfa.vfs.cloud9.us-east-2.amazonaws.com/users/#{@user.id}")
                        #redirect_to(user_url(@user.id))絶対パスの変換
                        #redirect_to(user_url(@user))@userは自動的にidにリンク
                        #redirect_to(@user)_urlヘルパーは省略可能
    else
      render 'new'
    end
  end

  private
  #このuser_paramsメソッドはUsersコントローラの内部でのみ実行され、
  #Web経由で外部ユーザーにさらされる必要はないため、
  #リスト 7.19に示すようにRubyのprivateキーワードを使って外部から使えないようにします
  #(privateキーワードの詳細については 9.1で説明します)。
    def user_params
      #
      params.require(:user).permit(:name, :email, :password, :password_confirmation )
    end
end
