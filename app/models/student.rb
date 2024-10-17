class Student < ApplicationRecord
  has_many :form_responses
  has_many :forms, through: :form_responses

  validates :uin, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
