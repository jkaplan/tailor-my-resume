class Contact < ApplicationRecord
  belongs_to :application

  validates :name, presence: true

  after_create :log_activity

  private

  def log_activity
    application.activity_logs.create!(
      activity_type: :contact_added,
      body: "Added contact: #{name}#{" (#{role})" if role.present?}"
    )
  end
end
