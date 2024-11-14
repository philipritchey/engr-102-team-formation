# view_form_steps.rb

When("I click on {string} for that form") do |button_text|
  # Ensure @form is set in a previous step
  expect(@form).to be_present, "No form is set. Make sure to create or set a form in a previous step."

  within('.form-card', text: @form.name) do
    click_link button_text
  end
end

Then("I should see {string} button") do |button_text|
  expect(page).to have_button(button_text)
end

Then("I should not see {string} button") do |button_text|
  expect(page).not_to have_button(button_text)
end
