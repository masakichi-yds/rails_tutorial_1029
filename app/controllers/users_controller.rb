class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index,:edit,:update,:destroy]
  before_action :current_user, only: [:edit,:update]
  before_action :admin_user, only: :destroy


  def index
    #cpaginateを使うことで、サンプルアプリケーションの
    #ユーザーのページネーションを行えるようになります。
    #具体的には、indexアクション内のallをpaginateメソッドに
    #置き換えます。ここで:pageパラメーターにはparams[:page]が
    #使われていますが、これはwill_paginateによって自動的に生成されます。
    @users = User.paginate(page: params[:page])
  end

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
      #登録された時点でログイン情報を与える
      #session[:user_id] = user.id
      log_in @user
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

  def edit
    #code
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  #ログインしているユーザーしか操作できないように制限
  def logged_in_user
    #ログインしてないなら
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    #別のユーザーのプロフィールを編集しようとしたらリダイレクトさせたいので
    #、correct_userというメソッドを作成し、beforeフィルターからこのメソッドを
    #呼び出すようにします if @current_user != session[:user_id]
    #flash[:danger] = ""
    #redirect_to root_url
    @user = User.find(params[:id])
    #redirect_to (root_url) unless @user == current_user
    #sessions_helperに
    redirect_to (root_url) unless current_user?(@user)
  end

  def admin_user
    #カレントユーザーが管理者で無いなら、redirect
    redirect_to(root_url) unless current_user.admin?
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
