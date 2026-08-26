class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :application, null: false, foreign_key: true
      t.string :name, null: false
      t.string :role
      t.string :email
      t.string :phone
      t.text :notes

      t.timestamps
    end
  end
end
