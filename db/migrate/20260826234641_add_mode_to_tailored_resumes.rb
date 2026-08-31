class AddModeToTailoredResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :tailored_resumes, :mode, :string, null: false, default: "ats"
  end
end
