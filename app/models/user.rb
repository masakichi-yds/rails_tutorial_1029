class User < ApplicationRecord
  #selfが省略、右辺。email現在のもの。
  #before_save {self.email = email.downcase}
  before_save {email.downcase!}
  #validates(:name, presence: truea)
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: {maximum: 255},
                    format: {with:VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive:false}
  has_secure_password
  validates :password, length: {minimum: 6}

  #渡された文字列のハッシュ値を返す
  #テスト中にそのユーザーとして自動ログインするために、
  #そのユーザーの有効なパスワードも用意して、
  #Sessionsコントローラのcreateアクションに送信されたパ
  #スワードと比較できるようにする必要があります。
  #password_digest属性をユーザーのfixtureに追加すればよいことが分かります。
  #そのために、digestメソッドを独自に定義することにします。
  #6.3.1で説明したように、has_secure_passwordでbcryptパスワードが作成されるので、
  #同じ方法でfixture用のパスワードを作成します。Railsのsecure_passwordのソースコードを調べてみると、
  #次の部分でパスワードが生成されていることが分かります。
  #この計算はユーザーごとに行う必要はないので、クラスメソッドにすることにしましょう 
  def User.digest(string)
    #本番環境ではセキュリティ上重要です。しかしテスト中はコストを高くする意味はないので、
    #digestメソッドの計算はなるべく軽くしておきたいです。この点についても、
    #secure_passwordのソースコードには次の行が参考になります。
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  #digestメソッドは、今後様々な場面で活用します。例えば9.1.1でもdigestを再利用するので、
  #このdigestメソッドはUserモデル (user.rb) に置いておきましょう。
end
