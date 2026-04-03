class CreateKsefSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :ksef_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      
      t.string :nip, null: false, limit: 10
      t.string :environment, null: false, default: "test"
      t.text :token

      t.timestamps
    end

    add_index :ksef_settings, [:user_id, :team_id], unique: true
    add_index :ksef_settings, :nip
  end
end
