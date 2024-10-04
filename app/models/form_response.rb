class FormResponse < ApplicationRecord
  belongs_to :form
  validates :uin, presence: true

  attribute :responses, :json, default: {}
end
