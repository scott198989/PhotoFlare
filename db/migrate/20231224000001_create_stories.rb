class CreateStories < ActiveRecord::Migration[7.0]
  def change
    create_table :stories do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :stories, :expires_at
    add_index :stories, :active
    add_index :stories, [:user_id, :active]
  end
end
