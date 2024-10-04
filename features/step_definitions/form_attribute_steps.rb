Given("I have created a form") do
  @form = Form.create!(name: "Test Form", description: "Test Description", user: @user)
end

When("I visit the edit page for the form") do
  visit edit_form_path(@form)
end

Then("I should see an option to add a new attribute") do
  expect(page).to have_content("Add Attribute")
end

When("I enter {string} as the attribute name") do |attribute_name|
  fill_in "Attribute Name", with: attribute_name
end

When("I select {string} as the attribute type") do |attribute_type|
  select attribute_type, from: "attribute_type"
end

When("I enter {string} as the minimum value") do |min_value|
  # Wait for the field to become visible
  expect(page).to have_field("Minimum Value", visible: true)
  fill_in "Minimum Value", with: min_value
end

When("I enter {string} as the maximum value") do |max_value|
  # Wait for the field to become visible
  expect(page).to have_field("Maximum Value", visible: true)
  fill_in "Maximum Value", with: max_value
end

When("I submit the new attribute") do
  click_button "Save Attribute"
end

Then("I should see {string} listed as an attribute on the form") do |attribute_name|
  expect(page).to have_content(attribute_name)
end

Then("I should see a success message") do
  expect(page).to have_content("Attribute was successfully added to the form.")
end

Then("the attribute {string} should be saved in the database") do |attribute_name|
  @form.reload  # Ensure we have the latest data from the database
  attribute = @form.form_attributes.find_by(name: attribute_name)
  expect(attribute).to be_present, "Attribute '#{attribute_name}' was not found in the database"
end

Then("the attribute {string} should have a scale from {int} to {int}") do |attribute_name, min, max|
  @form.reload  # Ensure we have the latest data from the database
  attribute = @form.form_attributes.find_by(name: attribute_name)
  expect(attribute).to be_present, "Attribute '#{attribute_name}' was not found in the database"
  expect(attribute.field_type).to eq('scale'), "Attribute '#{attribute_name}' is not a scale type"
  expect(attribute.min_value).to eq(min), "Minimum value for '#{attribute_name}' is incorrect"
  expect(attribute.max_value).to eq(max), "Maximum value for '#{attribute_name}' is incorrect"
end
