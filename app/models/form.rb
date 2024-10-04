# The Form model represents a form in the application
# It defines associations with users and attributes, and includes validations
class Form < ApplicationRecord
  # Associations

  # Each form belongs to a user
  # This sets up a one-to-many relationship from User to Form
  belongs_to :user

  # A form can have many attributes (questions/fields)
  # The 'dependent: :destroy' option ensures that when a form is deleted, all its attributes are also deleted
  # 'class_name: "Attribute"' specifies that the associated model is actually called Attribute, not FormAttribute
  has_many :form_attributes, dependent: :destroy, class_name: "Attribute"

  # This allows attributes to be created, updated, or destroyed through the form
  # It's useful for nested forms in views where you want to manage attributes alongside the form
  has_many :form_responses, dependent: :destroy
  accepts_nested_attributes_for :form_attributes, allow_destroy: true

  # Validations

  # Ensures that every form has a name
  # The 'uniqueness: true' option ensures that no two forms can have the same name
  validates :name, presence: true, uniqueness: true

  # Ensures that every form has a description
  validates :description, presence: true
end
