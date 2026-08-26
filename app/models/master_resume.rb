class MasterResume < ApplicationRecord
  has_one_attached :source_pdf

  def self.current
    first_or_create!(content: "")
  end
end
