class ActivityLog < ApplicationRecord
  belongs_to :application

  enum :activity_type, {
    status_change: 0,
    note: 1,
    tailor_run: 2,
    contact_added: 3
  }

  validates :body, presence: true

  default_scope { order(created_at: :desc) }
end
