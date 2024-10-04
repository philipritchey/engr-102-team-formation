# This step creates a user with professor credentials and logs them in
Given("I am logged in as a professor") do
  # Create a new user in the database
  @user = User.create!(name: "Professor", email: "professor@example.com", uin: "123456789")
  # Simulate a logged-in session for this user
  page.set_rack_session(user_id: @user.id)
end

# This step navigates to the user's profile page
When("I navigate to my user profile page") do
  # Visit the user's show page
  visit user_path(@user)
end

# This step clicks on a link with the given text
When("I click on {string}") do |link_text|
  click_link link_text
end

# This step checks if the form for entering basic form details is present
Then("I should see a form to enter basic form details") do
  # Check if the "Name" field is present
  expect(page).to have_field("Name")
  # Check if the "Description" field is present
  expect(page).to have_field("Description")
end

# This step fills in the form name and description
When("I fill in the form name and description") do
  fill_in "Name", with: "New Test Form"
  fill_in "Description", with: "This is a test form description"
end

# This step clicks a button with the given text
When("I click {string}") do |button_text|
  click_button button_text
end

# This step checks if the user is redirected to the form edit page
Then("I should be redirected to the form edit page") do
  # Check if the current path is the edit path for the last created form
  expect(page).to have_current_path(edit_form_path(Form.last))
end

# This step checks if options to add attributes to the form are present
Then("I should see options to add attributes to the form") do
  expect(page).to have_content("Add Attribute")
end

# This step creates a form with a given name
Given("a form with the name {string} already exists") do |form_name|
  @existing_form = Form.create!(name: form_name, description: "Existing form description", user: @user)
end

# This step fills in the form name
When("I fill in the form name with {string}") do |name|
  fill_in "Name", with: name
end

# This step fills in the form description
When("I fill in the form description with {string}") do |description|
  fill_in "Description", with: description
end

# This step checks for the presence of an error message
Then("I should see an error message {string}") do |message|
  expect(page).to have_content(message)
end

# This step checks if the user remains on the new form page
Then("I should remain on the new form page") do
  expect(page).to have_current_path(forms_path, ignore_query: true)
end

# This step clicks on a specific action for a specific form
When("I click on {string} for {string}") do |action, form_name|
  within('table.table-striped') do
    row = find('tr', text: form_name)
    within(row) do
      click_link action
    end
  end
end

# This step checks if the user is on the show page for a specific form
Then("I should be on the show page for {string}") do |form_name|
  @form = Form.find_by(name: form_name)
  expect(page).to have_current_path(form_path(@form))
end

# This step checks if the form details are displayed
Then("I should see the form details") do
  expect(page).to have_content(@form.name)
  expect(page).to have_content(@form.description)
end

# This step checks for the presence of a table of forms
Then("I should see a table of forms") do
  expect(page).to have_css('table.table-striped')
end

# This step checks if a specific form name is in the forms table
Then("I should see {string} in the forms table") do |form_name|
  within('table.table-striped') do
    expect(page).to have_content(form_name)
  end
end

# This step checks if a specific form name is in the list of forms
Then("I should see {string} in the list of forms") do |form_name|
  within('table.table-striped') do
    expect(page).to have_content(form_name)
  end
end
