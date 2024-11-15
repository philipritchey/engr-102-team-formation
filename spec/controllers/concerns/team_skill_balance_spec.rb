require 'rails_helper'

RSpec.describe TeamSkillBalance do
  let(:user) { create(:user) }
  let(:dummy_class) { Class.new { include TeamCalculation; include TeamEthnicityBalance; include TeamSkillBalance } }
  let(:instance) { dummy_class.new }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    @form = create(:form, user: user, name: "Skill Balance Form", published: false)

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
      options: "asian,caucasian,african,hispanic,middle_eastern,pacific_islander"
    )

    # Set up attributes for skill levels
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

  context "with a diverse skill set of students" do
    before do
      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
           2
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "caucasian",
           5
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
           9
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          7
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "female" : "male",
          "middle_eastern",
          8
        )
      end
      @team_distribution = instance.calculate_teams
    end

    it "balances teams based on skill levels when the team_avg is average and unassigned students are fairly distributed" do
      distribution = @team_distribution

      section_data = distribution["A"]

      # Team 1: Has two students already assigned low => 1 and high => 1 and spots_left => 2
      team1 = section_data[:teams][0]
      instance.send(:assign_student_to_team, section_data, 1, team1)
      instance.send(:assign_student_to_team, section_data, 5, team1)
      # Team 2: Has two students already assigned medium => 1 and high => 1 and spots_left => 1
      team2 = section_data[:teams][1]
      instance.send(:assign_student_to_team, section_data, 3, team2)
      instance.send(:assign_student_to_team, section_data, 7, team2)
      # Team 3: Has two students already assigned low => 1 and high => 1 and spots_left => 1
      team3 = section_data[:teams][2]
      instance.send(:assign_student_to_team, section_data, 2, team3)
      instance.send(:assign_student_to_team, section_data, 6, team3)

      section_a = distribution["A"]

      updated_distribution = instance.balance_by_skills(distribution)

      section_a = updated_distribution["A"]

      puts "\nTeam Distribution after balancing by skills basic scenario:"
      section_a[:teams].each do |team|
        puts "\nTeam #{team[:team_id]}:"
        puts "Members: #{team[:members].reject(&:zero?).size}/#{team[:capacity]}"
        puts "Skill composition: #{team[:composition][:skill]}"
        puts "Average skill: #{instance.send(:calculate_team_average, section_a, team).round(2)}"

        team_avg = instance.send(:calculate_team_average, section_a, team).round(2)

        # Since the team_avg was in medium range and remaining students were fairly ditributed team_avg after balancing should be average too
        expect(team_avg).to be_between(5, 7).inclusive
      end

      puts "\n\nFull Data Structure:"
      puts "Section A:"
      puts "  Total students: #{section_a[:students].size}"
      puts "  Unassigned students: #{section_a[:unassigned].size}"

      puts "\n  Students by skill level:"
      section_a[:by_skill].each do |level, students|
        puts "    #{level}: #{students.size} students"
      end

      puts "\n  Teams structure:"
      pp section_a[:teams]
    end
  end

  context "with a skill set skewed towards high" do
    before do
      11.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
           10
        )
      end

      @team_distribution = instance.calculate_teams
    end

    it "balances teams based on skill levels when the team_avg is high and remaining students are also high" do
      distribution = @team_distribution

      section_data = distribution["A"]

      # Team 1: Has three students already assigned high => 3 and spots_left => 1
      team1 = section_data[:teams][0]
      instance.send(:assign_student_to_team, section_data, 1, team1)
      instance.send(:assign_student_to_team, section_data, 5, team1)
      instance.send(:assign_student_to_team, section_data, 7, team1)
      # Team 2: Has two students already assigned high => 2 and spots_left => 2
      team2 = section_data[:teams][1]
      instance.send(:assign_student_to_team, section_data, 3, team2)
      instance.send(:assign_student_to_team, section_data, 2, team2)

      updated_distribution = instance.balance_by_skills(distribution)

      section_a = updated_distribution["A"]

      section_a[:teams].each do |team|
        team_avg = instance.send(:calculate_team_average, section_a, team).round(2)

        # Since the team_avg was in high range and remaining students were also high range the team_avg should also be high
        expect(team_avg).to be_between(8, 10).inclusive
      end
    end
  end

  context "with a diverse skill set of students after ethnicity balancing" do
    before do
      10.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
           2
        )
      end

      10.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "female" : "male",
          "hispanic",
           5
        )
      end

      10.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
           9
        )
      end

      10.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          7
        )
      end

      10.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "female" : "male",
          "middle_eastern",
          8
        )
      end
      @team_distribution = instance.calculate_teams
    end

    it "balances teams based on skill levels when after ethnicity" do
      distribution = instance.balance_by_ethnicity(@team_distribution)

      section_a = distribution["A"]

      puts "\nTeam Distribution before balancing by skills after ethnicity:"
      section_a[:teams].each do |team|
        puts "\nTeam #{team[:team_id]}:"
        puts "Members: #{team[:members].reject(&:zero?).size}/#{team[:capacity]}"
        puts "Skill composition: #{team[:composition][:skill]}"
        puts "Average skill: #{instance.send(:calculate_team_average, section_a, team).round(2)}"
      end

      updated_distribution = instance.balance_by_skills(distribution)

      section_a = updated_distribution["A"]

      puts "\nTeam Distribution after balancing by skills after ethnicity:"
      section_a[:teams].each do |team|
        puts "\nTeam #{team[:team_id]}:"
        puts "Members: #{team[:members].reject(&:zero?).size}/#{team[:capacity]}"
        puts "Skill composition: #{team[:composition][:skill]}"
        puts "Average skill: #{instance.send(:calculate_team_average, section_a, team).round(2)}"

        team_avg = instance.send(:calculate_team_average, section_a, team).round(2)

        # Team average is in the medium range between 4 to 8
        expect(team_avg).to be_between(4, 8).inclusive
      end
    end
  end

  context "only one student is left for assigning" do
    before do
      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
           2
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "caucasian",
           5
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
           9
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          7
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "female" : "male",
          "middle_eastern",
          8
        )
      end
      @team_distribution = instance.calculate_teams
    end

    it "balances teams based on skill levels when only one student is left to be assigned" do
      distribution = @team_distribution

      section_data = distribution["A"]

      # Team 1: Already full
      team1 = section_data[:teams][0]
      instance.send(:assign_student_to_team, section_data, 1, team1)
      instance.send(:assign_student_to_team, section_data, 5, team1)
      instance.send(:assign_student_to_team, section_data, 8, team1)
      instance.send(:assign_student_to_team, section_data, 4, team1)
      # Team 2: Has two students already assigned medium => 1 and high => 1 and spots_left => 1
      team2 = section_data[:teams][1]
      instance.send(:assign_student_to_team, section_data, 3, team2)
      instance.send(:assign_student_to_team, section_data, 7, team2)
      # Team 3: Already full
      team3 = section_data[:teams][2]
      instance.send(:assign_student_to_team, section_data, 2, team3)
      instance.send(:assign_student_to_team, section_data, 6, team3)
      instance.send(:assign_student_to_team, section_data, 9, team3)
      section_a = distribution["A"]

      updated_distribution = instance.balance_by_skills(distribution)

      section_a = updated_distribution["A"]

      puts "\nTeam Distribution after balancing by skills:"
      section_a[:teams].each do |team|
        team_avg = instance.send(:calculate_team_average, section_a, team).round(2)

        # only one student was left to assign assigned proerly and team_avg is maintained
        expect(team_avg).to be_between(5, 7).inclusive
      end
    end
  end

  context "with a diverse skill set of students for 2 sections" do
    before do
      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
           2
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "caucasian",
           5
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
           9
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          7
        )
      end

      2.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "female" : "male",
          "middle_eastern",
          8
        )
      end

      2.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "male" : "female",
          "asian",
           2
        )
      end

      2.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "male" : "female",
          "caucasian",
           3
        )
      end

      2.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "male" : "female",
          "hispanic",
           10
        )
      end

      2.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "male" : "female",
          "middle_eastern",
          10
        )
      end

      2.times do |i|
        create_student_with_response(
          "B",
          i.even? ? "female" : "male",
          "middle_eastern",
          10
        )
      end
      @team_distribution = instance.calculate_teams
    end

    it "balances teams based on skill levels when the team_avg is average and unassigned students are fairly distributed" do
      distribution = @team_distribution

      section_data = distribution["A"]

      # Team 1: Has two students already assigned low => 1 and high => 1 and spots_left => 2
      team1 = section_data[:teams][0]
      instance.send(:assign_student_to_team, section_data, 1, team1)
      instance.send(:assign_student_to_team, section_data, 5, team1)
      # Team 2: Has two students already assigned medium => 1 and high => 1 and spots_left => 1
      team2 = section_data[:teams][1]
      instance.send(:assign_student_to_team, section_data, 3, team2)
      instance.send(:assign_student_to_team, section_data, 7, team2)
      # Team 3: Has two students already assigned low => 1 and high => 1 and spots_left => 1
      team3 = section_data[:teams][2]
      instance.send(:assign_student_to_team, section_data, 2, team3)
      instance.send(:assign_student_to_team, section_data, 6, team3)

      section_data = distribution["B"]

      # Team 1: Has two students already assigned low =>2 and spots_left => 2
      team1 = section_data[:teams][0]
      instance.send(:assign_student_to_team, section_data, 11, team1)
      instance.send(:assign_student_to_team, section_data, 15, team1)
      # Team 2: Has two students already assigned high => 2 and spots_left => 1
      team2 = section_data[:teams][1]
      instance.send(:assign_student_to_team, section_data, 13, team2)
      instance.send(:assign_student_to_team, section_data, 17, team2)
      # Team 3: Has two students already assigned low => 2 and spots_left => 1
      team3 = section_data[:teams][2]
      instance.send(:assign_student_to_team, section_data, 12, team3)
      instance.send(:assign_student_to_team, section_data, 16, team3)

      updated_distribution = instance.balance_by_skills(distribution)

      section_a = updated_distribution["A"]

      section_a[:teams].each do |team|
        team_avg = instance.send(:calculate_team_average, section_a, team).round(2)

        # Since the team_avg was in medium range and remaining students were fairly ditributed team_avg after balancing should be average too
        expect(team_avg).to be_between(5, 7).inclusive
      end

      section_b = updated_distribution["B"]

      section_b[:teams].each do |team|
        team_avg = instance.send(:calculate_team_average, section_b, team).round(2)

        # Since the team_avg was in medium range and remaining students were fairly ditributed team_avg after balancing should be average too
        expect(team_avg).to be_between(5, 8).inclusive
      end
    end
  end
end
