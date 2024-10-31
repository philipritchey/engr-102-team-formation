# Most steps can be reused from other files, we only need these new ones:

When("I click on {string} for that form") do |button_text|
  within('tr', text: @form.name) do
    click_link button_text
  end
end

Then("I should see {string} button") do |button_text|
  expect(page).to have_content(button_text)
end

Then("I should not see {string} button") do |button_text|
  expect(page).not_to have_content(button_text)
end
