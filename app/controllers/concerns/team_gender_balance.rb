module TeamGenderBalance
  extend ActiveSupport::Concern
  include TeamDistributionHelpers

  # Input: team_distribution hash with structure:
  # {
  #   "A" => {
  #     students: Set[{student_id, gender, ethnicity, assigned, average, team_id, level}],
  #     by_gender: { "male" => Set[student_ids], "female" => Set[student_ids] },
  #     by_ethnicity: { ethnicity => Set[student_ids] },
  #     by_skill: { "low" => Set[ids], "medium" => Set[ids], "high" => Set[ids] },
  #     unassigned: Set[student_ids],
  #     teams: [{team_id, capacity, members[], composition{}, spots_left}]
  #   }
  # }
  #
  # Output: Modified team_distribution with balanced gender distribution
  def balance_by_gender(team_distribution)
    team_distribution.each do |section, section_data|
    # Step 1: Assign female students in pairs
    assign_female_students(section_data)

    # Check if there are multiple unassigned females left; if so, stop further assignments
    unassigned_females = filter_students(section_data, gender: "female")
    return team_distribution if unassigned_females.size > 1

    # Step 2: Assign any single remaining female student
    assign_single_female_to_team(section_data)

    # Step 3: Assign 'other' gender students
    assign_others_to_teams(section_data)
    end
      team_distribution
  end

  private

  # Helper methods
  def assign_female_students(section_data)
    unassigned_females = filter_students(section_data, gender: "female")
    return if unassigned_females.size < 2

    section_data[:teams].each do |team|
      break if unassigned_females.size < 2

      pair_found = find_and_assign_pair(section_data, unassigned_females, team)

      break if unassigned_females.size == 1
    end
  end

  # Helper method to find and assign a pair of female students to a team
  def find_and_assign_pair(section_data, unassigned_females, team)
    unassigned_females.each do |student1_id|
      student1 = find_student(section_data, student1_id)
      potential_pairs = get_potential_pairs(unassigned_females, student1_id)
      match_id = find_matching_pair(section_data, student1, potential_pairs.to_a)

      if match_id.nil? && unassigned_females.size > 1
        # If no match is found with strict skill level matching, try without skill constraints
        match_id = potential_pairs.first
      end

      if match_id
        assign_pair_to_team(section_data, student1_id, match_id, team)
        unassigned_females.delete(student1_id)
        unassigned_females.delete(match_id)
        return true
      end
    end
    false
  end

  # Helper method to find a student by ID
  def find_student(section_data, student_id)
    section_data[:students].find { |s| s[:student_id] == student_id }
  end

  # Helper method to get potential pairs excluding the current student
  def get_potential_pairs(unassigned_females, current_id)
    unassigned_females - [ current_id ]
  end

  # Helper method to assign both students to the team
  def assign_pair_to_team(section_data, student1_id, match_id, team)
    assign_student_to_team(section_data, student1_id, team)
    assign_student_to_team(section_data, match_id, team)
  end


  def assign_single_female_to_team(section_data)
    unassigned_females = filter_students(section_data, gender: "female")
    return unless unassigned_females.size == 1

    student_id = unassigned_females.first
    # Find a team with exactly 2 females and an available spot (no need to ensure uniqueness for single female assignment)
    team = section_data[:teams].find do |t|
      t[:composition][:gender]["female"] == 2 && t[:spots_left] > 0
    end

    return unless team
    assign_student_to_team(section_data, student_id, team)
  end

  def assign_others_to_teams(section_data)
    unassigned_others = filter_students(section_data, gender: "other")
    return if unassigned_others.empty?

    # Keep track of teams that have already received an 'other' student
    teams_with_others = Set.new

    unassigned_others.each do |student_id|
      # Find a team with exactly 2 females, an available spot, and no other student assigned yet
      team = find_unique_team_with_two_females(section_data, teams_with_others)
      break unless team

      assign_student_to_team(section_data, student_id, team)
      teams_with_others.add(team[:team_id]) # Mark this team as having an 'other' student
    end
  end
end

def find_unique_team_with_two_females(section_data, teams_with_others)
  teams_with_two_females = section_data[:teams].select do |team|
    team[:composition][:gender]["female"] == 2 &&
    team[:spots_left] > 0 &&
    !teams_with_others.include?(team[:team_id])
  end
  teams_with_two_females.find { |team| team[:capacity] == 4 } || teams_with_two_females.find { |team| team[:capacity] == 3 }
end
