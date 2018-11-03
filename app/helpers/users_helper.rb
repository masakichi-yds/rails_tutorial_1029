module UsersHelper
   # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user)
    #Digestライブラリのhexdigestメソッドを使うと、MD5のハッシュ化が実現できます。
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    #Gravatarの画像タグにgravatarクラスとユーザー名のaltテキストを追加したものを返します
    #(altテキストを追加しておくと、視覚障害のあるユーザーがスクリーンリーダーを使うときにも役に立ちます)。
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
