require 'rails_helper'

RSpec.describe TeamCalculation do
  let(:user) { create(:user) }
  let(:dummy_class) { Class.new { include TeamCalculation } }
  let(:instance) { dummy_class.new }

  before do
    # Simulate user login
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    @form = create(:form, user: user, name: "Test Form", published: false)

    # Create form attributes
    @gender_attr = create(:attribute,
      form: @form,
      name: "gender",
      field_type: "mcq",
      options: "male,female"
    )

    @ethnicity_attr = create(:attribute,
      form: @form,
      name: "ethnicity",
      field_type: "mcq",
      options: "asian,caucasian,african"
    )

    @skill_attr = create(:attribute,
      form: @form,
      name: "programming_skill",
      field_type: "scale",
      min_value: 1,
      max_value: 10,
      weightage: 1
    )

    instance.instance_variable_set(:@form, @form)
  end

  def create_student_with_response(section, gender, ethnicity, skill_level)
    student = create(:student, section: section)
    create(:form_response,
      form: @form,
      student: student,
      responses: {
        @gender_attr.id.to_s => gender,
        @ethnicity_attr.id.to_s => ethnicity,
        @skill_attr.id.to_s => skill_level
      }
    )
  end

  context "with different section sizes" do
    it "handles a section with exactly 8 students (two teams of 4)" do
      # Create 8 students in section A
      8.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          [ "asian", "caucasian", "african" ][i % 3],
          rand(1..10)
        )
      end

      result = instance.calculate_teams
      section_a_data = result["A"]

      expect(section_a_data[:teams].length).to eq(2)
      expect(section_a_data[:teams].all? { |team| team[:capacity] == 4 }).to be true
    end

    it "handles a section with 7 students (one team of 4, one team of 3)" do
      7.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "male" : "female",
          [ "asian", "caucasian", "african" ][i % 3],
          rand(1..10)
        )
      end

      result = instance.calculate_teams
      section_b_data = result["B"]

      expect(section_b_data[:teams].length).to eq(2)
      expect(section_b_data[:teams].map { |team| team[:capacity] }.sort).to eq([ 3, 4 ])
    end

    it "handles a large section with 12 students (three teams of 4)" do
      12.times do |i|
        create_student_with_response(
          "C",
          i.even? ? "male" : "female",
          [ "asian", "caucasian", "african" ][i % 3],
          rand(1..10)
        )
      end

      result = instance.calculate_teams
      section_c_data = result["C"]

      expect(section_c_data[:teams].length).to eq(3)
      expect(section_c_data[:teams].all? { |team| team[:capacity] == 4 }).to be true
    end

    it "handles a section with 6 students (two teams of 3)" do
      6.times do |i|
        create_student_with_response(
          "F",
          i.even? ? "male" : "female",
          [ "asian", "caucasian", "african" ][i % 3],
          rand(1..10)
        )
      end

      result = instance.calculate_teams
      section_f_data = result["F"]

      expect(section_f_data[:teams].length).to eq(2)
      expect(section_f_data[:teams].all? { |team| team[:capacity] == 3 }).to be true
    end

    it "handles a section with 9 students (three teams of 3)" do
      9.times do |i|
        create_student_with_response(
          "G",
          i.even? ? "male" : "female",
          [ "asian", "caucasian", "african" ][i % 3],
          rand(1..10)
        )
      end

      result = instance.calculate_teams
      section_g_data = result["G"]

      expect(section_g_data[:teams].length).to eq(3)
      expect(section_g_data[:teams].all? { |team| team[:capacity] == 3 }).to be true
    end
  end

  context "error handling" do
    it "raises error when gender attribute is missing" do
      @form.form_attributes.where(name: 'gender').destroy_all

      expect {
        instance.calculate_teams
      }.to raise_error("Gender attribute not found in form. Please ensure there is an MCQ attribute named 'gender'.")
    end

    it "raises error when ethnicity attribute is missing" do
      @form.form_attributes.where(name: 'ethnicity').destroy_all

      expect {
        instance.calculate_teams
      }.to raise_error("Ethnicity attribute not found in form. Please ensure there is an MCQ attribute named 'ethnicity'.")
    end

    it "raises error when gender attribute has no options" do
      @gender_attr.update(options: '')

      expect {
        instance.calculate_teams
      }.to raise_error("Gender attribute has no options defined. Please add options (e.g., 'male,female').")
    end

    it "raises error when ethnicity attribute has no options" do
      @ethnicity_attr.update(options: '')

      expect {
        instance.calculate_teams
      }.to raise_error("Ethnicity attribute has no options defined. Please add ethnicity options.")
    end
  end

  context "original basic test case" do
    before do
      # Create students and their responses in different sections
      create_student_with_response("A", "male", "asian", 8)
      create_student_with_response("A", "female", "caucasian", 6)
      create_student_with_response("A", "male", "african", 4)
      create_student_with_response("A", "female", "asian", 7)

      create_student_with_response("B", "male", "asian", 3)
      create_student_with_response("B", "female", "caucasian", 9)
      create_student_with_response("B", "male", "african", 5)
    end

    it "calculates teams correctly" do
      result = instance.calculate_teams

      expect(result.keys).to match_array([ "A", "B" ])

      section_a_data = result["A"]
      expect(section_a_data[:teams].length).to eq(1)
      expect(section_a_data[:teams].first[:capacity]).to eq(4)

      section_b_data = result["B"]
      expect(section_b_data[:teams].length).to eq(1)
      expect(section_b_data[:teams].first[:capacity]).to eq(3)
      puts "\nFull result structure:"
      pp result
    end
  end

  context "default values" do
    it "returns first gender option as default gender" do
      # Since we defined options as "male,female" in the before block,
      # "male" should be the default
      expect(instance.send(:default_gender)).to eq("male")
    end

    it "returns first ethnicity option as default ethnicity" do
      # Since we defined options as "asian,caucasian,african" in the before block,
      # "asian" should be the default
      expect(instance.send(:default_ethnicity)).to eq("asian")
    end

    it "handles different gender options order" do
      @gender_attr.update(options: "female,male")
      expect(instance.send(:default_gender)).to eq("female")
    end

    it "handles different ethnicity options order" do
      @ethnicity_attr.update(options: "caucasian,asian,african")
      expect(instance.send(:default_ethnicity)).to eq("caucasian")
    end
  end
end
