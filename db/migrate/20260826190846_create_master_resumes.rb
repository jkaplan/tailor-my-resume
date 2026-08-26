class CreateMasterResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :master_resumes do |t|
      t.text :content

      t.timestamps
    end
  end
end
