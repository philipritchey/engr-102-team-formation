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
      sorted_teams = section_data[:teams].sort_by do |team|
        calculate_team_average(section_data, team)
      end

      # Step 2: Sort students by skill level (ascending)
      sorted_students = sort_unassigned_students_by_level(section_data, unassigned)

      # Step 3: Assign students to teams in round-robin fashion (one student per team)
      sorted_teams.each do |team|
        next unless team_has_empty_spot?(team)  # Skip teams with no empty spots

        # Exit if there are no students left to assign
        return if sorted_students.empty?

        # Step 4: Get the current average skill level of the team
        team_avg = calculate_team_average(section_data, team)
        
        # Step 5: Get student id of best suited student by skill
        student_id = find_student_id_to_fill(team_avg, sorted_students, section_data)

        # Step 6: Assign the student to team
        student_assigned = assign_student_to_team(section_data, student_id, team)

        # Step 7: If assigned successfully then update unassigned students
        if student_assigned
          sorted_students.delete(student_id)
          unassigned.delete(student_id)
        end
      end
    end
  end

  def team_has_empty_spot?(team)
    team[:members].include?(0)
  end

  def sort_unassigned_students_by_level(section_data, unassigned)
    unassigned.sort_by { |student_id| get_student_level(section_data, student_id) }
  end

  def find_student_by_level(sorted_students, section_data, skill_levels)
    sorted_students.find do |student_id|
      skill_levels.include?(get_student_level(section_data, student_id))
    end
  end

  def find_student_id_to_fill(team_avg, sorted_students, section_data)
    if team_avg < 4
      # If the team's skill is low, assign a high-level or medium-level student
      find_student_by_level(sorted_students, section_data, ["high", "medium"]) ||
      sorted_students.shift  # If no high or medium, assign any available student
    elsif team_avg >= 4 && team_avg <= 7
      # If the team's skill is medium, assign a high-level or medium-level student
      find_student_by_level(sorted_students, section_data, ["high", "medium"]) ||
      sorted_students.shift  # If no high or medium, assign any available student
    else
      # If the team's skill is high, assign a low-level or medium-level student
      find_student_by_level(sorted_students, section_data, ["low", "medium"]) ||
      sorted_students.shift  # If no low or medium, assign any available student
    end
  end
  private

  # Additional helper methods
end
