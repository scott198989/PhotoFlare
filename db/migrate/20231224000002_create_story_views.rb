class CreateStoryViews < ActiveRecord::Migration[7.0]
  def change
    create_table :story_views do |t|
      t.references :story, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :viewed_at, null: false

      t.timestamps
    end

    add_index :story_views, [:story_id, :user_id], unique: true
  end
end
