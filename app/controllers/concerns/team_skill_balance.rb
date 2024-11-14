module TeamSkillBalance
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
  # Output: Modified team_distribution with balanced skill levels
  def balance_by_skills(team_distribution)
    team_distribution.each do |section, section_data|
      balance_sections_by_skills(section_data)
    end
    team_distribution
  end

  def balance_sections_by_skills(section_data)
    unassigned = filter_students(section_data)
    return if unassigned.empty? 
    while unassigned.size>0

      # Step 1: Sort teams by their current average skill level (ascending)
      sorted_teams = sort_teams_by_average(section_data)

      # Step 2: Sort students by skill level (ascending)
      sorted_students = sort_unassigned_students_by_level(section_data, unassigned)

      # Step 3: Assign students to teams in round-robin fashion (one student per team)
      assign_students_to_teams(section_data, sorted_teams, sorted_students, unassigned)
    end
  end

  def sort_teams_by_average(section_data)
    section_data[:teams].sort_by do |team|
      calculate_team_average(section_data, team)
    end
  end

  def sort_unassigned_students_by_level(section_data, unassigned)
    unassigned.sort_by { |student_id| get_student_level(section_data, student_id) }
  end

  # Main function to assign students to teams
  def assign_students_to_teams(section_data, sorted_teams, sorted_students, unassigned)
    sorted_teams.each do |team|
      next unless team_has_empty_spot?(team)  # Skip teams with no empty spots

      # Exit if there are no students left to assign
      return if sorted_students.empty?

      assign_student_to_team_if_possible(section_data, team, sorted_students, unassigned)
    end
  end

  def team_has_empty_spot?(team)
    team[:members].include?(0)
  end

  # Function to handle the assignment process for a single team
  def assign_student_to_team_if_possible(section_data, team, sorted_students, unassigned)
    team_avg = calculate_team_average(section_data, team)  # Step 4: Calculate team average skill
    student_id = find_student_id_to_fill(team_avg, sorted_students, section_data)  # Step 5: Find suitable student
    
    # Step 6: Assign student to team and update assignment status if successful
    if assign_student_to_team(section_data, student_id, team)
      update_student_assignment_status(student_id, sorted_students, unassigned)
    end
  end

  def find_student_id_to_fill(team_avg, sorted_students, section_data)
    if team_avg < 4
      find_student_for_low_skill_team(sorted_students, section_data)
    elsif team_avg >= 4 && team_avg <= 7
      find_student_for_medium_skill_team(sorted_students, section_data)
    else
      find_student_for_high_skill_team(sorted_students, section_data)
    end
  end

  # Function to update assignment status for a student
  def update_student_assignment_status(student_id, sorted_students, unassigned)
    sorted_students.delete(student_id)
    unassigned.delete(student_id)
  end

  def find_student_for_low_skill_team(sorted_students, section_data)
    find_student_by_level(sorted_students, section_data, ["high", "medium"]) || sorted_students.shift
  end
  
  def find_student_for_medium_skill_team(sorted_students, section_data)
    find_student_by_level(sorted_students, section_data, ["high", "medium"]) || sorted_students.shift
  end
  
  def find_student_for_high_skill_team(sorted_students, section_data)
    find_student_by_level(sorted_students, section_data, ["low", "medium"]) || sorted_students.shift
  end

  def find_student_by_level(sorted_students, section_data, skill_levels)
    sorted_students.find do |student_id|
      skill_levels.include?(get_student_level(section_data, student_id))
    end
  end
  private

  # Additional helper methods
end
