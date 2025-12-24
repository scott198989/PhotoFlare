class CreateConversationParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at
      t.boolean :muted, default: false

      t.timestamps
    end

    add_index :conversation_participants, [:conversation_id, :user_id], unique: true
    add_index :conversation_participants, [:user_id, :last_read_at]
  end
end
