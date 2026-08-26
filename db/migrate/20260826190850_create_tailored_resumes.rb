class CreateTailoredResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :tailored_resumes do |t|
      t.references :application, null: false, foreign_key: true
      t.text :content, null: false
      t.text :rationale

      t.timestamps
    end
  end
end
