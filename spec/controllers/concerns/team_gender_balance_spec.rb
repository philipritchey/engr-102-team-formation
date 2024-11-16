require 'rails_helper'

RSpec.describe TeamGenderBalance do
  let(:user) { create(:user) }
  let(:dummy_class) { Class.new { include TeamCalculation; include TeamDistributionHelpers; include TeamGenderBalance } }
  let(:instance) { dummy_class.new }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    @form = create(:form, user: user, name: "Gender Balance Test Form", published: false)
    @gender_attr = create(:attribute, form: @form, name: "gender", field_type: "mcq", options: "female,male,other,prefer not to say")
    @ethnicity_attr = create(:attribute, form: @form, name: "ethnicity", field_type: "mcq", options: "asian,caucasian")
    @skill_attr = create(:attribute, form: @form, name: "programming_skill", field_type: "scale", min_value: 1, max_value: 10, weightage: 1)
    instance.instance_variable_set(:@form, @form)
  end

  def create_student_with_response(section, gender, ethnicity = "asian", skill_level)
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
  context "large group with odd number of females (e.g., 21 females, 20 males, 5 others)" do
    before do
      21.times { create_student_with_response("A", "female", rand(1..10)) }
      20.times { create_student_with_response("A", "male", rand(1..10)) }
      5.times { create_student_with_response("A", "other", rand(1..10)) }
      @initial_distribution = instance.calculate_teams
    end

    it "handles odd number of female students, ensuring one team with 3 females if needed" do
      section_data = @initial_distribution["A"]
      puts "Pre-balancing Distribution:"
      print_distribution(section_data)

      result = instance.balance_by_gender(@initial_distribution)
      section_a = result["A"]

      puts "Post-balancing Distribution:"
      print_distribution(section_a)

      puts "\n\nFull Data Structure:"
      puts "Section A:"
      puts "  Total students: #{section_a[:students].size}"
      puts "  Unassigned students: #{section_a[:unassigned].size}"
      puts "\n  Students by gender:"
      section_a[:by_gender].each do |gender, students|
        puts "    #{gender}: #{students.size} students"
      end
      puts "\n  Students by ethnicity:"
      section_a[:by_ethnicity].each do |ethnicity, students|
        puts "    #{ethnicity}: #{students.size} students"
      end
      puts "\n  Students by skill level:"
      section_a[:by_skill].each do |level, students|
        puts "    #{level}: #{students.size} students"
      end
      puts "\n  Teams structure:"
      pp section_a[:teams]

      female_counts = section_a[:teams].map { |team| team[:composition][:gender]["female"].to_i }
      expect(female_counts.count(2)).to be >= 5
      expect(female_counts.count(3)).to be <= 1

      other_counts = section_a[:teams].map { |team| team[:composition][:gender]["other"].to_i }
      expect(other_counts.sum).to eq(5)
    end
  end

  context "large group with even number of females (e.g., 24 females, 25 males, 4 others)" do
    before do
      24.times { create_student_with_response("A", "female", rand(1..10)) }
      25.times { create_student_with_response("A", "male", rand(1..10)) }
      4.times { create_student_with_response("A", "other", rand(1..10)) }
      @initial_distribution = instance.calculate_teams
    end

    it "handles even number of female students, ensuring all teams with females have 2 females" do
      section_data = @initial_distribution["A"]
      puts "Pre-balancing Distribution:"
      print_distribution(section_data)

      result = instance.balance_by_gender(@initial_distribution)
      section_a = result["A"]

      puts "Post-balancing Distribution:"
      print_distribution(section_a)

      puts "\n\nFull Data Structure:"
      puts "Section A:"
      puts "  Total students: #{section_a[:students].size}"
      puts "  Unassigned students: #{section_a[:unassigned].size}"
      puts "\n  Students by gender:"
      section_a[:by_gender].each do |gender, students|
        puts "    #{gender}: #{students.size} students"
      end
      puts "\n  Students by ethnicity:"
      section_a[:by_ethnicity].each do |ethnicity, students|
        puts "    #{ethnicity}: #{students.size} students"
      end
      puts "\n  Students by skill level:"
      section_a[:by_skill].each do |level, students|
        puts "    #{level}: #{students.size} students"
      end
      puts "\n  Teams structure:"
      pp section_a[:teams]

      female_counts = section_a[:teams].map { |team| team[:composition][:gender]["female"].to_i }
      expect(female_counts.count(2)).to be >= 12
      expect(female_counts.include?(3)).to be false

      other_counts = section_a[:teams].map { |team| team[:composition][:gender]["other"].to_i }
      expect(other_counts.sum).to eq(4)
    end
  end

  context "more females than teams can handle in a larger group (e.g., 30 females, 20 males, 5 others)" do
    before do
      30.times { create_student_with_response("A", "female", rand(1..10)) }
      20.times { create_student_with_response("A", "male", rand(1..10)) }
      5.times { create_student_with_response("A", "other", rand(1..10)) }
      @initial_distribution = instance.calculate_teams
    end

    it "assigns maximum 2 females per team when females exceed team count" do
      section_data = @initial_distribution["A"]
      puts "Pre-balancing Distribution:"
      print_distribution(section_data)

      result = instance.balance_by_gender(@initial_distribution)
      section_a = result["A"]

      puts "Post-balancing Distribution:"
      print_distribution(section_a)

      puts "\n\nFull Data Structure:"
      puts "Section A:"
      puts "  Total students: #{section_a[:students].size}"
      puts "  Unassigned students: #{section_a[:unassigned].size}"
      puts "\n  Students by gender:"
      section_a[:by_gender].each do |gender, students|
        puts "    #{gender}: #{students.size} students"
      end
      puts "\n  Students by ethnicity:"
      section_a[:by_ethnicity].each do |ethnicity, students|
        puts "    #{ethnicity}: #{students.size} students"
      end
      puts "\n  Students by skill level:"
      section_a[:by_skill].each do |level, students|
        puts "    #{level}: #{students.size} students"
      end
      puts "\n  Teams structure:"
      pp section_a[:teams]

      female_counts = section_a[:teams].map { |team| team[:composition][:gender]["female"].to_i }
      expect(female_counts.count(2)).to eq(section_a[:teams].size)

      other_counts = section_a[:teams].map { |team| team[:composition][:gender]["other"].to_i }
      expect(other_counts.sum).to be <= 5
    end
  end

  # Method to print team distribution for debugging
  def print_distribution(section_data)
    puts "\nTeams Analysis:"
    section_data[:teams].each do |team|
      puts "\nTeam #{team[:team_id]}:"
      puts "Members: #{team[:members].reject(&:zero?).join(', ')}"
      puts "Gender composition: #{team[:composition][:gender]}"
      team[:members].reject(&:zero?).each do |id|
        student = section_data[:students].find { |s| s[:student_id] == id }
        puts "Student #{id}: level=#{student[:level]}, average=#{student[:average]}, gender=#{student[:gender]}"
      end
      team_avg = instance.send(:calculate_team_average, section_data, team)
      puts "Team Average Skill: #{team_avg.round(2)}"
    end
    puts "\nUnassigned students: #{section_data[:unassigned].size}"
    puts "Unassigned students by gender:"
    section_data[:by_gender].each do |gender, students|
      unassigned_students = students & section_data[:unassigned]
      puts "  #{gender}: #{unassigned_students.size} students"
    end
  end
end
