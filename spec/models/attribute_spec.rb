# This file contains RSpec tests for the Attribute model
# It covers associations, validations, and custom validations for different field types
# These tests ensure that Attribute instances are created and validated correctly

require 'rails_helper'

RSpec.describe Attribute, type: :model do
  # Create a form for testing attributes
  let(:form) { create(:form) }

  describe "associations" do
    it "belongs to a form" do
      # Test if the Attribute model has a belongs_to association with Form
      attribute = Attribute.reflect_on_association(:form)
      expect(attribute.macro).to eq :belongs_to
    end
  end

  describe "validations" do
    it "validates presence of name" do
      # Test if an attribute without a name is invalid
      attribute = build(:attribute, name: nil)
      expect(attribute).to be_invalid
      expect(attribute.errors[:name]).to include("can't be blank")
    end

    it "validates presence of field_type" do
      # Test if an attribute without a field_type is invalid
      attribute = build(:attribute, field_type: nil)
      expect(attribute).to be_invalid
      expect(attribute.errors[:field_type]).to include("can't be blank")
    end

    it "validates inclusion of field_type" do
      # Test if only valid field types are accepted
      valid_types = %w[text_input mcq scale]
      valid_types.each do |type|
        attribute = build(:attribute, field_type: type)
        expect(attribute).to be_valid
      end

      # Test if an invalid field type is rejected
      attribute = build(:attribute, field_type: 'invalid_type')
      expect(attribute).to be_invalid
      expect(attribute.errors[:field_type]).to include("is not included in the list")
    end
  end

  describe "custom validations" do
    context "when field_type is 'scale'" do
      let(:attribute) { build(:attribute, form: form, field_type: 'scale', min_value: min_value, max_value: max_value) }

      context "with valid scale range" do
        let(:min_value) { 1 }
        let(:max_value) { 10 }

        it "is valid" do
          # Test if a scale attribute with valid range is accepted
          expect(attribute).to be_valid
        end
      end

      context "with invalid scale range" do
        let(:min_value) { 10 }
        let(:max_value) { 1 }

        it "is invalid" do
          # Test if a scale attribute with invalid range (min > max) is rejected
          expect(attribute).to be_invalid
          expect(attribute.errors[:min_value]).to include("must be less than max value")
        end
      end
    end

    context "when field_type is 'mcq'" do
      let(:attribute) { build(:attribute, form: form, field_type: 'mcq', options: options) }

      context "with valid options" do
        let(:options) { "Option 1, Option 2" }

        it "is valid" do
          # Test if an MCQ attribute with valid options is accepted
          expect(attribute).to be_valid
        end
      end

      context "with invalid options" do
        let(:options) { "Single Option" }

        it "is invalid" do
          # Test if an MCQ attribute with only one option is rejected
          expect(attribute).to be_invalid
          expect(attribute.errors[:options]).to include("must have at least two options")
        end
      end
    end
  end

  describe "field types" do
    it "allows text_input field type" do
      # Test if text_input is a valid field type
      attribute = build(:attribute, form: form, field_type: 'text_input')
      expect(attribute).to be_valid
    end

    it "allows mcq field type" do
      # Test if mcq is a valid field type (with valid options)
      attribute = build(:attribute, form: form, field_type: 'mcq', options: "Option 1, Option 2")
      expect(attribute).to be_valid
    end

    it "allows scale field type" do
      # Test if scale is a valid field type (with valid range)
      attribute = build(:attribute, form: form, field_type: 'scale', min_value: 1, max_value: 10)
      expect(attribute).to be_valid
    end

    it "does not allow invalid field type" do
      # Test if an invalid field type is rejected
      attribute = build(:attribute, form: form, field_type: 'invalid_type')
      expect(attribute).to be_invalid
      expect(attribute.errors[:field_type]).to include("is not included in the list")
    end
  end
end
