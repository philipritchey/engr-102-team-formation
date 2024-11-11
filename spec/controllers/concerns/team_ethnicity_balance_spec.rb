require 'rails_helper'

RSpec.describe TeamEthnicityBalance do
  let(:user) { create(:user) }
  let(:dummy_class) { Class.new { include TeamCalculation; include TeamEthnicityBalance } }
  let(:instance) { dummy_class.new }

  before do
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
      options: "asian,caucasian,african,hispanic,middle_eastern,pacific_islander"
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
        "gender" => gender,
        "ethnicity" => ethnicity,
        "programming_skill" => skill_level
      }
    )
  end

  context "with large diverse section" do
    before do
      # Section A: 50 students
      # Minority threshold = 50/4 = 12.5

      # asian: 20 students (not minority)
      20.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
          rand(1..10)
        )
      end

      # caucasian: 15 students (not minority)
      15.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "caucasian",
          rand(1..10)
        )
      end

      # hispanic: 8 students (minority)
      8.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
          [ 3, 5, 6, 7, 8, 4, 9, 5 ][i]  # Specific skill levels for better testing
        )
      end

      # middle_eastern: 7 students (minority)
      7.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          [ 4, 7, 8, 3, 6, 5, 9 ][i]  # Mix of skill levels
        )
      end

      # pacific_islander: 0 students (to test nil/empty case)
      # No students created for this ethnicity

      @initial_distribution = instance.calculate_teams
    end

    it "identifies correct minority groups" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      total_students = 50
      minority_threshold = total_students / 4.0  # 12.5

      # Check minorities
      expect(section_a[:by_ethnicity]["hispanic"].size).to be < minority_threshold
      expect(section_a[:by_ethnicity]["middle_eastern"].size).to be < minority_threshold

      # Check non-minorities
      expect(section_a[:by_ethnicity]["asian"].size).to be >= minority_threshold
      expect(section_a[:by_ethnicity]["caucasian"].size).to be >= minority_threshold

      # Check empty ethnicity
      expect(section_a[:by_ethnicity]["pacific_islander"].size).to eq(0)
    end

    it "keeps minority students together" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      minority_ethnicities = [ "hispanic", "middle_eastern" ]

      minority_ethnicities.each do |ethnicity|
        teams_with_ethnicity = section_a[:teams].select do |team|
          team[:composition][:ethnicity][ethnicity].to_i > 0
        end

        teams_with_ethnicity.each do |team|
          count = team[:composition][:ethnicity][ethnicity]
          expect(count).to be >= 2,
            "Found #{count} #{ethnicity} student(s) in team #{team[:team_id]}, expected at least 2"
        end
      end
    end

    it "handles empty ethnicity groups gracefully" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      expect(section_a[:by_ethnicity]["pacific_islander"]).to be_empty
      expect(section_a[:teams].any? { |t| t[:composition][:ethnicity]["pacific_islander"].to_i > 0 }).to be false
    end

    # Add debugging output to see actual distributions
    it "prints team distributions" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      puts "\nTeam Distribution Analysis:"
      section_a[:teams].each do |team|
        puts "\nTeam #{team[:team_id]}:"
        puts "Members: #{team[:members].reject(&:zero?).size}/#{team[:capacity]}"
        puts "Ethnic composition: #{team[:composition][:ethnicity]}"
        puts "Average skill: #{instance.send(:calculate_team_average, section_a, team).round(2)}"
      end

      puts "\n\nFull Data Structure:"
      puts "Section A:"
      puts "  Total students: #{section_a[:students].size}"
      puts "  Unassigned students: #{section_a[:unassigned].size}"
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
    end
  end

  context "with pre-populated teams" do
    def create_prepopulated_distribution
      distribution = instance.calculate_teams
      section_data = distribution["A"]

      # Team 1: One isolated hispanic student (minority)
      team1 = section_data[:teams][0]
      hispanic_student = section_data[:students].find { |s|
        s[:ethnicity] == "hispanic" && s[:level] == "high"
      }
      instance.send(:assign_student_to_team, section_data, hispanic_student[:student_id], team1)

      # Team 2: One isolated middle_eastern student (minority)
      team2 = section_data[:teams][1]
      middle_eastern_student = section_data[:students].find { |s|
        s[:ethnicity] == "middle_eastern" && s[:level] == "medium"
      }
      instance.send(:assign_student_to_team, section_data, middle_eastern_student[:student_id], team2)

      # Team 3: Mixed team with majority students
      team3 = section_data[:teams][2]
      asian_students = section_data[:students].select { |s| s[:ethnicity] == "asian" }.take(2)
      asian_students.each do |student|
        instance.send(:assign_student_to_team, section_data, student[:student_id], team3)
      end

      # Team 4: Nearly full team with space for one more
      team4 = section_data[:teams][3]
      caucasian_students = section_data[:students].select { |s| s[:ethnicity] == "caucasian" }.take(3)
      caucasian_students.each do |student|
        instance.send(:assign_student_to_team, section_data, student[:student_id], team4)
      end

      # Team 5: One isolated hispanic student with low skill
      team5 = section_data[:teams][4]
      hispanic_low = section_data[:students].find { |s|
        s[:ethnicity] == "hispanic" &&
        s[:level] == "low" &&
        !s[:assigned]  # Make sure we get an unassigned student
      }
      instance.send(:assign_student_to_team, section_data, hispanic_low[:student_id], team5)

      distribution
    end

    before do
      # Create students with specific skill levels for better testing
      # asian: 20 students (not minority)
      20.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "asian",
          case i % 3
          when 0 then rand(8..10)  # high
          when 1 then rand(4..7)   # medium
          else rand(1..3)          # low
          end
        )
      end

      # caucasian: 15 students (not minority)
      15.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "caucasian",
          case i % 3
          when 0 then rand(8..10)
          when 1 then rand(4..7)
          else rand(1..3)
          end
        )
      end

      # hispanic: 8 students (minority)
      skill_levels = [ 9, 8, 6, 6, 4, 4, 3, 3 ]  # Mix of high, medium, low
      8.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "hispanic",
          skill_levels[i]
        )
      end

      # middle_eastern: 7 students (minority)
      skill_levels = [ 8, 7, 6, 5, 4, 3, 2 ]  # Mix of high, medium, low
      7.times do |i|
        create_student_with_response(
          "A",
          i.even? ? "male" : "female",
          "middle_eastern",
          skill_levels[i]
        )
      end

      @initial_distribution = create_prepopulated_distribution
    end

    it "fixes isolated minority students" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      # Check Team 1 (had isolated hispanic)
      team1 = section_a[:teams][0]
      expect(team1[:composition][:ethnicity]["hispanic"]).to be >= 2,
        "Hispanic students weren't grouped together in Team 1"

      # Check Team 2 (had isolated middle_eastern)
      team2 = section_a[:teams][1]
      expect(team2[:composition][:ethnicity]["middle_eastern"]).to be >= 2,
        "Middle Eastern students weren't grouped together in Team 2"
    end

    it "maintains skill balance while fixing isolation" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      minority_ethnicities = [ "hispanic", "middle_eastern" ]

      section_a[:teams].each do |team|
        # Only check teams that have minority students
        next unless minority_ethnicities.any? { |ethnicity|
          team[:composition][:ethnicity][ethnicity].to_i > 0
        }

        team_avg = instance.send(:calculate_team_average, section_a, team)
        expect(team_avg).to be_between(3, 8),
          "Team #{team[:team_id]} with minorities has average (#{team_avg}) outside balanced range"
      end
    end

    it "respects team capacity constraints" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      section_a[:teams].each do |team|
        expect(team[:members].count { |m| m != 0 }).to be <= team[:capacity],
          "Team #{team[:team_id]} exceeds capacity"
        expect(team[:spots_left]).to eq(team[:capacity] - team[:members].count { |m| m != 0 }),
          "Team #{team[:team_id]} spots_left count is incorrect"
      end
    end

    it "updates unassigned students list correctly" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      assigned_students = section_a[:teams].flat_map { |t| t[:members] }.reject(&:zero?)
      expect(section_a[:unassigned].intersection(assigned_students)).to be_empty,
        "Found students that are both assigned and unassigned"
    end

    # Add debugging output
    it "prints pre and post balancing distributions" do
      puts "\nPre-balancing Distribution:"
      print_distribution(@initial_distribution["A"])

      result = instance.balance_by_ethnicity(@initial_distribution)

      puts "\nPost-balancing Distribution:"
      print_distribution(result["A"])
    end

    def print_distribution(section_data)
      puts "\nTeams Analysis:"
      section_data[:teams].each do |team|
        puts "\nTeam #{team[:team_id]}:"
        puts "Members: #{team[:members].reject(&:zero?).join(', ')}"
        puts "Composition: #{team[:composition][:ethnicity]}"

        # Add detailed skill level debugging
        team[:members].reject(&:zero?).each do |id|
          student = section_data[:students].find { |s| s[:student_id] == id }
          puts "Student #{id}: level=#{student[:level]}, average=#{student[:average]}"
        end

        team_avg = instance.send(:calculate_team_average, section_data, team)
        puts "Team Average: #{team_avg.round(2)}"
      end

      puts "\nUnassigned students: #{section_data[:unassigned].size}"
      puts "Students by ethnicity:"
      section_data[:by_ethnicity].each do |ethnicity, students|
        puts "  #{ethnicity}: #{students.size} students"
      end
    end

    it "maintains overall skill distribution" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      team_averages = section_a[:teams].map do |team|
        next nil if team[:members].count { |m| m != 0 } < 2
        instance.send(:calculate_team_average, section_a, team)
      end.compact

      avg_difference = team_averages.max - team_averages.min
      expect(avg_difference).to be <= 5,
        "Team averages vary too widely: min=#{team_averages.min}, max=#{team_averages.max}"
    end

    it "balances team with isolated low-skill minority student" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      # Check Team 5 (had isolated low-skill hispanic student)
      team5 = section_a[:teams][4]
      expect(team5[:composition][:ethnicity]["hispanic"]).to be >= 2,
        "Hispanic students weren't grouped together in Team 5"

      # Verify skill balance was achieved
      final_avg = instance.send(:calculate_team_average, section_a, team5)
      expect(final_avg).to be > 4,
        "Team average wasn't improved after balancing"

      # Verify at least one high-skill hispanic student was added
      hispanic_members = team5[:members].reject(&:zero?).select do |member_id|
        student = section_a[:students].find { |s| s[:student_id] == member_id }
        student[:ethnicity] == "hispanic"
      end

      skill_levels = hispanic_members.map do |member_id|
        student = section_a[:students].find { |s| s[:student_id] == member_id }
        student[:level]
      end

      expect(skill_levels).to include("high"),
        "No high-skill hispanic student was added to balance the low-skill student"
    end
  end

  context "with specific team distribution" do
    before do
      # Update ethnicity options to include our test ethnicities
      @ethnicity_attr.update(options: "ma,m1,m2")

      # Section A: 24 students total
      # Minority threshold = 24/4 = 6
      # ma: 17 students (majority)
      # m1: 5 students (minority)
      # m2: 2 students (minority)

      # ma: 17 students (majority)
      17.times do |i|
        create_student_with_response(
          "A", "male", "ma",
          case i % 3
          when 0 then rand(7..9)  # high
          when 1 then rand(4..6)  # medium
          else rand(1..3)         # low
          end
        )
      end

      # m1: 5 students (minority)
      5.times do |i|
        create_student_with_response(
          "A", "male", "m1",
          case i % 3
          when 0 then rand(7..9)
          when 1 then rand(4..6)
          else rand(1..3)
          end
        )
      end

      # m2: 2 students (minority)
      2.times do |i|
        create_student_with_response(
          "A", "male", "m2",
          [ 3, 7 ][i]  # one low, one high
        )
      end

      @initial_distribution = create_specific_distribution
    end

    def create_specific_distribution
      distribution = instance.calculate_teams
      section_data = distribution["A"]

      # Set team capacities to 4
      section_data[:teams].each { |team| team[:capacity] = 4 }

      # Team 1: 2 ma, 1 m1
      team1 = section_data[:teams][0]
      2.times do
        student = section_data[:students].find { |s| s[:ethnicity] == "ma" && !s[:assigned] }
        instance.send(:assign_student_to_team, section_data, student[:student_id], team1)
      end
      student = section_data[:students].find { |s| s[:ethnicity] == "m1" && !s[:assigned] }
      instance.send(:assign_student_to_team, section_data, student[:student_id], team1)

      # Team 2: 2 ma, 2 m2
      team2 = section_data[:teams][1]
      2.times do
        student = section_data[:students].find { |s| s[:ethnicity] == "ma" && !s[:assigned] }
        instance.send(:assign_student_to_team, section_data, student[:student_id], team2)
      end
      section_data[:students].select { |s| s[:ethnicity] == "m2" && !s[:assigned] }.each do |student|
        instance.send(:assign_student_to_team, section_data, student[:student_id], team2)
      end

      # Teams 3-5: 3 ma each
      (2..4).each do |i|
        team = section_data[:teams][i]
        3.times do
          student = section_data[:students].find { |s| s[:ethnicity] == "ma" && !s[:assigned] }
          instance.send(:assign_student_to_team, section_data, student[:student_id], team)
        end
      end

      # Team 6: 4 ma
      team6 = section_data[:teams][5]
      4.times do
        student = section_data[:students].find { |s| s[:ethnicity] == "ma" && !s[:assigned] }
        instance.send(:assign_student_to_team, section_data, student[:student_id], team6)
      end

      distribution
    end

    it "assigns single m1 student when pairing isn't possible" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      # The remaining m1 students should be assigned individually
      # since there aren't enough spots in any single team
      teams_with_single_m1 = section_a[:teams].select do |team|
        team[:composition][:ethnicity]["m1"].to_i == 1
      end

      expect(teams_with_single_m1.size).to be >= 2,
        "Expected multiple teams with single m1 students"
    end

    it "uses teams with available spots when no other options exist" do
      result = instance.balance_by_ethnicity(@initial_distribution)
      section_a = result["A"]

      # Verify all m1 students were assigned somewhere
      total_m1_assigned = section_a[:teams].sum do |team|
        team[:composition][:ethnicity]["m1"].to_i
      end

      expect(total_m1_assigned).to eq(5),
        "Not all m1 students were assigned when forced to use available spots"
    end
  end
end
