class CreateHashtags < ActiveRecord::Migration[7.0]
  def change
    create_table :hashtags do |t|
      t.string :name, null: false
      t.integer :posts_count, default: 0

      t.timestamps
    end

    add_index :hashtags, :name, unique: true
    add_index :hashtags, :posts_count
  end
end
