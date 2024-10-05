# This step creates a user associated with the current context (e.g., for tests)
Given("I am logged in as professor") do
    @user = User.create!(email: "user@example.com", name: "user", uin:"12345")
    page.set_rack_session(user_id: @user.id)
end
  
  # This step creates a form associated with the current user with attributes
  Given("I have created a form with attributes for preview") do
    @form = Form.create!(name: "Test Form", description: "Test Description", user: @user)
    @form.form_attributes.create!(name: "Question 2", field_type: "text_input")
  end
  
  # This step navigates to the edit page of the previously created form
  When("I visit the edit page for the form to preview") do
    visit edit_form_path(@form)
  end
  
  
  Then("I should see a button to preview the form") do
    expect(page).to have_button("Preview Form")
  end

  When("I click the {string} button") do |button_text|
    click_button button_text
  end
  
  Then("I should see the preview modal") do
    visit preview_form_path(@form)
  end
  
  
  Then("I should see the preview title as {string}") do |form_name|
    visit preview_form_path(@form)
    expect(page).to have_content("Preview Form: #{form_name}")
  end
  