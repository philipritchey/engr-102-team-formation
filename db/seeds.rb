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
