class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body
      t.datetime :read_at
      t.string :message_type, default: 'text'
      t.references :shared_post, foreign_key: { to_table: :posts }

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :message_type
  end
end
