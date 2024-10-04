Given("I am logged in as a professor") do
  @user = User.create!(name: "Professor", email: "professor@example.com", uin: "123456789")
  page.set_rack_session(user_id: @user.id)
end

When("I navigate to my user profile page") do
  visit user_path(@user)
end

When("I click on {string}") do |link_text|
  click_link link_text
end

Then("I should see a form to enter basic form details") do
  expect(page).to have_field("Name")
  expect(page).to have_field("Description")
end

When("I fill in the form name and description") do
  fill_in "Name", with: "New Test Form"
  fill_in "Description", with: "This is a test form description"
end

When("I click {string}") do |button_text|
  click_button button_text
end

Then("I should be redirected to the form edit page") do
  expect(page).to have_current_path(edit_form_path(Form.last))
end

Then("I should see options to add attributes to the form") do
  expect(page).to have_content("Add Attribute")
  # Add more specific expectations based on your form edit page layout
end

# Add these new step definitions to your existing file

Given("a form with the name {string} already exists") do |form_name|
  @existing_form = Form.create!(name: form_name, description: "Existing form description", user: @user)
end

When("I fill in the form name with {string}") do |name|
  fill_in "Name", with: name
end

When("I fill in the form description with {string}") do |description|
  fill_in "Description", with: description
end

Then("I should see an error message {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should remain on the new form page") do
  expect(page).to have_current_path(forms_path, ignore_query: true)
end

When("I click on {string} for {string}") do |action, form_name|
  within('table.table-striped') do
    row = find('tr', text: form_name)
    within(row) do
      click_link action
    end
  end
end

Then("I should be on the show page for {string}") do |form_name|
  @form = Form.find_by(name: form_name)
  expect(page).to have_current_path(form_path(@form))
end

Then("I should see the form details") do
  expect(page).to have_content(@form.name)
  expect(page).to have_content(@form.description)
  # Add more expectations for other form details you want to verify
end

# You might also want to add these helper steps

Then("I should see a table of forms") do
  expect(page).to have_css('table.table-striped')
end

Then("I should see {string} in the forms table") do |form_name|
  within('table.table-striped') do
    expect(page).to have_content(form_name)
  end
end

Then("I should see {string} in the list of forms") do |form_name|
  within('table.table-striped') do
    expect(page).to have_content(form_name)
  end
end
