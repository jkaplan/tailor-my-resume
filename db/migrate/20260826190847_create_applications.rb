class CreateApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :applications do |t|
      t.string :company, null: false
      t.string :role_title, null: false
      t.string :job_url
      t.text :job_description
      t.integer :status, null: false, default: 0
      t.date :applied_date
      t.date :follow_up_date

      t.timestamps
    end

    add_index :applications, :status
    add_index :applications, :follow_up_date
  end
end
