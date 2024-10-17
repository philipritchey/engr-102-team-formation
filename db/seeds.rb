# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
students = [
  { uin: '123456789', name: 'Alice Smith', email: 'alice.smith@example.com', section: 'A' },
  { uin: '987654321', name: 'Bob Johnson', email: 'bob.johnson@example.com', section: 'B' },
  { uin: '456789123', name: 'Charlie Brown', email: 'charlie.brown@example.com', section: 'C' },
  { uin: '321654987', name: 'Daisy Ridley', email: 'daisy.ridley@example.com', section: 'A' },
  { uin: '789123456', name: 'Ethan Hunt', email: 'ethan.hunt@example.com', section: 'B' }
]

students.each do |student_attributes|
  Student.create!(student_attributes)
end

puts "Created #{Student.count} students."

# Fetch the existing user (user 1)
user = User.find(1)

# Create a form for user 1
form = Form.create!(
  name: "Course Evaluation Form New 3",
  description: "Please provide your feedback on the course content and delivery",
  user: user,
  deadline: 2.weeks.from_now,
  published: false
)

# Create two attributes for the form
Attribute.create!(
  name: "Programming Proficiency New 3",
  field_type: "Scale",
  min_value: 1,
  max_value: 5,
  form: form,
  weightage: 0.7
)

Attribute.create!(
  name: "Gender",
  field_type: "text",
  form: form,
  weightage: 0.3
)

# Create a new student
student = Student.create!(
  uin: "107654321",
  name: "Dwayne Johnson",
  email: "dwayne.johnson@example.com",
  section: "C"
)

# Create a form response
FormResponse.create!(
  form: form,
  student: student,
  responses: {}.to_json
)

puts "New seed data created successfully!"
