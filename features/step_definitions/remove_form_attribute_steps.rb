  Given('that {string} is a current attribute') do |attribute_name|
    @attribute = @form.form_attributes.create(name: attribute_name, field_type: "text_input")
    @form.reload
  end

  When("I click on {string} for {string} field") do |action, attribute_name|
    within('ul') do
      attributes_list = all('li')
      target_li = attributes_list.find { |li| li.text.include?(attribute_name) }
      if target_li
        within(target_li) do
          click_button action
        end
      else
        raise "Could not find list item containing '#{attribute_name}'. Available attributes: #{attributes_list.map(&:text)}"
      end
    end
  end

  Then('I should not see {string} in the current attributes') do |attribute_name|
    expect(page).not_to have_content(attribute_name)
  end
