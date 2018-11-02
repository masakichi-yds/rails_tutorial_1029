class CreateUsers < ActiveRecord::Migration[5.2]
#マイグレーション自体は、データベースに与える変更を定義したchangeメソッドの集まりです
  def change
    #changeメソッドはcreate_tableというRailsのメソッドを呼び、
    #ユーザーを保存するためのテーブルをデータベースに作成します。
    #create_tableメソッドはブロック変数を1つ持つブロック (4.3.2) を受け取ります。
    #ここでは (“table”の頭文字を取って) tです。
    #そのブロックの中でcreate_tableメソッドはtオブジェクトを使って、nameとemailカラムをデータベースに作ります。
    create_table :users do |t|
      t.string :name
      t.string :email

      #ブロックの最後の行t.timestampsは特別なコマンドで、c
      #reated_atとupdated_atという２つの「マジックカラム (Magic Columns)」を作成します。
      t.timestamps
    end
  end
end
