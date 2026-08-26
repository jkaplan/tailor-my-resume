class Application < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :tailored_resumes, dependent: :destroy

  enum :status, {
    saved: 0,
    applied: 1,
    phone_screen: 2,
    interview: 3,
    offer: 4,
    rejected: 5,
    withdrawn: 6
  }, default: :saved

  validates :company, presence: true
  validates :role_title, presence: true
  validates :job_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  after_update :log_status_change, if: :saved_change_to_status?

  def current_tailored_resume
    tailored_resumes.order(created_at: :desc).first
  end

  def follow_up_overdue?
    follow_up_date.present? && follow_up_date < Date.current
  end

  private

  def log_status_change
    was, now = saved_change_to_status
    activity_logs.create!(
      activity_type: :status_change,
      body: "Status changed from #{was} to #{now}"
    )
  end
end
