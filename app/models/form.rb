class Form < ApplicationRecord
  belongs_to :user
  has_many :form_attributes, dependent: :destroy, class_name: "Attribute"
  accepts_nested_attributes_for :form_attributes, allow_destroy: true

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
