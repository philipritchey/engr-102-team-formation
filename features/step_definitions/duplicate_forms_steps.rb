Given("I am logged in as the professor") do
    @user = User.create!(email: "user@example.com", name: "user", uin: "12345")
    page.set_rack_session(user_id: @user.id)
end

  # This step creates a form associated with the current user with attributes
  Given("I have created a form with attributes") do
    @form = Form.create!(name: "Test Form", description: "Test Description", user: @user)
    @form.form_attributes.create!(name: "Question 2", field_type: "text_input")
  end

  # This step navigates to the edit page of the previously created form
  When("I visit the edit page for form") do
    visit edit_form_path(@form)
  end

  Then("I should see a button to duplicate the form") do
    expect(page).to have_button("Duplicate Form")
  end

  When("I click {string} ") do |button_text|
    click_button button_text
  end

  Then('I should be redirected to the edit page for the duplicated form') do
    expect(current_path).to eq(edit_form_path(Form.last)) # Assuming the last form is the duplicated one
  end
