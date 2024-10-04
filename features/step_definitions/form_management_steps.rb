Given("I am on the form management page") do
  visit forms_path
end

When("I click on {string}") do |button_text|
  click_on button_text
end

Then("I should see a new form page") do
  expect(page).to have_current_path(new_form_path)
  expect(page).to have_content("New Form")
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

Then("I should be on the edit page for {string}") do |form_name|
  form = Form.find_by(name: form_name)
  expect(page).to have_current_path(edit_form_path(form))
end

Then("I should see a button to add attributes") do
  expect(page).to have_button("Save Attribute")
end

Given("I am on the edit page for {string}") do |form_name|
  @form = create(:form, name: form_name)
  @form_id = @form.id
  visit edit_form_path(@form)
end

When("I select {string} from {string}") do |option, select_field|
  select_field = "attribute_type" if select_field == "Attribute Type"
  select option, from: select_field
  puts "Selected '#{option}' from '#{select_field}'"
  sleep 2  # Add a 2-second sleep after selection
  puts "Current page HTML after selection and sleep:"
  puts page.html
end

Then("the scale fields should be visible") do
  sleep 2  # Add a 2-second sleep before checking visibility
  expect(page).to have_css("#scale_fields", visible: true)
  expect(page).to have_field("attribute_min_value", visible: true)
  expect(page).to have_field("attribute_max_value", visible: true)
  puts "Scale fields visibility check passed"
  puts "Current page HTML after visibility check:"
  puts page.html
end

And("I fill in the min value with {string}") do |value|
  sleep 2  # Add a 2-second sleep before filling in the value
  begin
    fill_in "attribute_min_value", with: value
    puts "Successfully filled in min value with #{value}"
  rescue Capybara::ElementNotFound => e
    puts "Error: #{e.message}"
    puts "Current page HTML:"
    puts page.html
    raise e
  end
end

And("I fill in the max value with {string}") do |value|
  sleep 2  # Add a 2-second sleep before filling in the value
  begin
    fill_in "attribute_max_value", with: value
    puts "Successfully filled in max value with #{value}"
  rescue Capybara::ElementNotFound => e
    puts "Error: #{e.message}"
    puts "Current page HTML:"
    puts page.html
    raise e
  end
end

Then("I should see {string} in the list of attributes") do |attribute_name|
  within('ul') do
    expect(page).to have_content(attribute_name)
  end
end

Then("I should see {string} for {string}") do |details, attribute_name|
  within('ul') do
    expect(page).to have_content(attribute_name)
    expect(page).to have_content(details)
  end
end

Given("the form has an attribute named {string}") do |attribute_name|
  create(:attribute, form: @form, name: attribute_name)
end

When("I click on {string} for the attribute {string}") do |action, attribute_name|
  within('ul') do
    within("li", text: attribute_name) do
      click_button action
    end
  end
end

Then("I should not see {string} in the list of current attributes") do |attribute_name|
  within('ul') do
    expect(page).not_to have_content(attribute_name)
  end
end

Given("there are multiple forms in the system") do
  create(:form, name: "Form 1")
  create(:form, name: "Form 2")
  create(:form, name: "Form 3")
end

Then("I should see a list of all forms") do
  expect(page).to have_content("Form 1")
  expect(page).to have_content("Form 2")
  expect(page).to have_content("Form 3")
end

Then("each form should have options to view, edit, and delete") do
  expect(page).to have_link("View", count: 3)
  expect(page).to have_link("Edit", count: 3)
  expect(page).to have_link("Delete", count: 3)
end

Then("show me the page") do
  puts page.html
  puts "Current URL: #{page.current_url}"
  save_and_open_page
end

Then("the form should exist in the database") do
  @form.reload
  expect(Form.exists?(@form_id)).to be true
  puts "Form exists in database with ID: #{@form_id}"  # Debug output
  puts "Total forms in database: #{Form.count}"  # Additional debug output
  puts "All form IDs in database: #{Form.pluck(:id)}"  # More debug output
end
