module ApplicationHelper
  #ページごとに完全なタイトルを返す
  #デフォルト値が引数＝空で引数がきたら、空文字になるそしてbase_titleのみの表示
  def full_title(page_title = "")
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + "|" + base_title
    end
  end
end
