class FormResponse < ApplicationRecord
  belongs_to :form
  belongs_to :student

  validates :student_id, presence: true
  validates :form_id, uniqueness: { scope: :student_id }
  validates :responses, presence: true

  attribute :responses, :json, default: {}
end
