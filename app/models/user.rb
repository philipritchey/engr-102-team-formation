class User < ApplicationRecord
  has_many :forms, dependent: :destroy
  validates :email, presence: true
end
