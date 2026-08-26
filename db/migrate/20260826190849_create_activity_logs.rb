class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :application, null: false, foreign_key: true
      t.integer :activity_type, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
