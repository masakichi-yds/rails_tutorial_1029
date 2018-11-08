class User < ApplicationRecord
  #remember_tokenを追加できるように
  #マイグレーションを行ってあるので、Userモデルには既にremember_digest属性が追加されていますが、
  #remember_token属性はまだ追加されていません。
  #user.remember_tokenでトークンにアクセス出来るように、
  #かつトークンをデータベースに保存せずに実装する必要があるため
  #attr_accessorを使ってアクセス可能な属性を作成している
  attr_accessor :remember_token
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

  #ユーザーを記憶するには、記憶トークンを作成して、
  #そのトークンをダイジェストに変換したものをデータベースに保存します。
  #fixtureをテストするときにdigestメソッドを既に作成してあったので (リスト 8.21)、
  #上の結論に従って、新しいトークンを作成するためのnew_tokenメソッドを作成できます。
  #この新しいdigestメソッドではユーザーオブジェクトが不要なので、
  #このメソッドもUserモデルのクラスメソッドとして作成することにします
  def User.new_token
    #ランダムなトークンを返す
    SecureRandom.urlsafe_base64
  end

  #rememberメソッドの1行目の代入にご注目ください。selfというキーワードを使わないと、
  #Rubyによってremember_tokenという名前のローカル変数が作成されてしまいます。
  #この動作は、Rubyにおけるオブジェクト内部への要素代入の仕様によるものです。
  #今欲しいのはローカル変数ではありません。
  #selfキーワードを与えると、この代入によってユーザーのremember_token属性が期待どおりに設定されます
  # (他のbefore_saveコールバックで、emailではなくself.emailと記述していた理由。
  #rememberメソッドの２行目では、update_attributeメソッドを使って記憶ダイジェストを更新しています。
  #6.1.5で説明したように、このメソッドはバリデーションを素通りさせます。
  #今回はユーザーのパスワードやパスワード確認にアクセスできないので、
  #バリデーションを素通りさせなければなりません。
  #以上の点を考慮して、有効なトークンとそれに関連するダイジェストを作成できるようにします。
  def remember
    #最初にUser.new_tokenで記憶トークンを作成し
    #selfを付けないとremember_tokenがローカル変数になってしまうただの変数代入になってしまうのがRuby。
    #今欲しいのはローカル変数ではありません。
    #selfキーワードを与えると、この代入によってユーザーのremember_token属性が期待どおりに設定されます
    self.remember_token = User.new_token
    #続いてUser.digest(記憶トークンを暗号化)を適用した結果で記憶ダイジェストを更新します。
    #update_attributeメソッドを使って記憶ダイジェストを更新しています。
    #このメソッドはバリデーションを素通りさせます。
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  #渡されたトークンがユーザーの記憶ダイジェストと一致することを確認します。
  #この一致をbcryptで確認するための様々な方法があります。
  #secure_passwordのソースコードを調べてみると、次のような比較を行っている箇所があります9。

  #BCrypt::Password.new(password_digest) == unencrypted_password

  #今回の場合、上のコードを参考に下のようなコードを使います。

  #BCrypt::Password.new(remember_digest) == remember_token

  #このコードをじっくり調べてみると、実に奇妙なつくりになっています。
  #bcryptで暗号化されたパスワードを、トークンと直接比較しています。ということは、==で比較する際にダイジェストを復号化しているのでしょうか。しかし、bcryptのハッシュは復号化できないはずなので、復号化しているはずはありません。そこでbcrypt gemのソースコードを詳しく調べてみると、なんと、比較に使っている==演算子が再定義されています。実際の比較をコードで表すと、次のようになっています。

  #BCrypt::Password.new(remember_digest).is_password?(remember_token)

  def authenticated?(remember_token)
    #記憶ダイジェストがnilの場合にはreturnキーワードで即座にメソッドを終了しています。
    #処理を中途で終了する場合によく使われるテクニックです。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    #code
    update_attribute(:remember_digest, nil)
  end
end
