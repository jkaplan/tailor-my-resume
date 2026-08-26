class TailoredResume < ApplicationRecord
  belongs_to :application

  validates :content, presence: true

  after_create :log_activity

  private

  def log_activity
    application.activity_logs.create!(
      activity_type: :tailor_run,
      body: "Tailored resume generated"
    )
  end
end
