Given("I have created a form with a deadline") do
  # Specific logic for forms with a deadline
  @form = @user.forms.create!(name: "Form with Deadline", description: "Test Form with Deadline")
end

When("I visit the form edit page to manage deadlines") do
  visit edit_form_path(@form)
end

And ("I set the deadline to a future date and time") do
  # find('#deadline_picker').click
  fill_in 'deadline_picker', with: (Time.current + 1.day).strftime('%Y-%m-%dT%H:%M')
end

And ("I click {string} on the deadline page") do |button_text|
  click_button button_text
end

Then("the deadline should be successfully saved") do
  @form.reload
  expect(@form.deadline).to be > Time.now
end

# And ("I should see the updated deadline on the form page") do
#   visit form_path(@form)
#   expect(page).to have_content @form.deadline.strftime("%B %d, %Y %H:%M")
# end


Given("I have created a form with a set deadline") do
  @form = Form.create!(name: "Test Form with Deadline", description: "Form Description", deadline: Time.now + 1.day, user: @user)
end


# Step definition for navigating to the user profile page
When("I navigate to my user profile page with set deadline") do
  visit user_path(@user)
end

# Step definition to check that the form is listed
Then("I should see {string} in the list of forms for deadline management") do |form_name|
  within('table.table-striped') do
    expect(page).to have_content(form_name)
  end
end

# Step definition for clicking on "Update Deadline" for the form
When("I click on {string} for {string} in the deadline Section") do |action, form_name|
  within('table.table-striped') do
    row = find('tr', text: form_name)  # Find the row containing the form_name
    within(row) do
      click_button action  # Click the button with the given action text
    end
  end
end

# Step definition for selecting a new future deadline
When("I select a new future deadline for {string}") do |form_name|
  form = Form.find_by(name: form_name)
  within("#deadline-picker-#{form.id}") do
    fill_in "updated_deadline_#{form.id}", with: (Time.current + 2.days).strftime('%Y-%m-%dT%H:%M')
  end
end

# Step definition for clicking the Save button to save the updated deadline
When("I click {string} to save updated deadline for {string}") do |button_text, form_name|
  form = Form.find_by(name: form_name)
  within("#deadline-picker-#{form.id}") do
    click_button button_text
  end
end

# Step definition to check if the new deadline is successfully saved
Then("the new deadline should be successfully saved") do
  expect(page).to have_content("Deadline was successfully updated")
end

# Step definition to verify the updated deadline is visible on the user home page
Then("I should see the updated deadline on the user home page for {string}") do |form_name|
  within('table.table-striped') do
    row = find('tr', text: form_name)
    within(row) do
      expect(page).to have_content((Time.current + 2.days).strftime("%B %d, %Y %H:%M"))
    end
  end
end

When("I set the deadline to a past date and time") do
  fill_in "deadline_picker", with: (Time.now - 1.day).strftime("%Y-%m-%dT%H:%M")
end


Then("I should see an error message indicating {string}") do |error_message|
  expect(page).to have_content error_message
end

Then("the form should not be saved") do
  @form.reload
  expect(@form.deadline).to be_nil
end
