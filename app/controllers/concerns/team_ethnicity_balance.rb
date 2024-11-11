module TeamEthnicityBalance
  extend ActiveSupport::Concern
  include TeamDistributionHelpers

  def balance_by_ethnicity(team_distribution)
    team_distribution.each do |section, section_data|
      # Calculate minorities
      total_students = section_data[:students].size
      minority_threshold = total_students / 4.0

      ethnicity_counts = {}
      section_data[:by_ethnicity].each do |ethnicity, students|
        ethnicity_counts[ethnicity] = students.size
      end

      minority_groups = ethnicity_counts
        .select { |ethnicity, count| count < minority_threshold }
        .sort_by { |_, count| count }

      # Handle isolated students
      minority_groups.each do |ethnicity, _|
        handle_isolated_students(section_data, ethnicity)
      end

      # Handle remaining pairs
      minority_groups.each do |ethnicity, _|
        pair_remaining_students(section_data, ethnicity)
      end
    end

    team_distribution
  end

  private

  def handle_isolated_students(section_data, ethnicity)
    section_data[:teams].each do |team|
      # Initialize count if nil
      team[:composition][:ethnicity][ethnicity] ||= 0

      if team[:composition][:ethnicity][ethnicity] == 1
        return if team[:spots_left] <= 0  # Skip if team is full

        current_avg = calculate_team_average(section_data, team)
        needed_level = determine_needed_skill_level(current_avg)

        student_id = filter_students(section_data, {
          ethnicity: ethnicity,
          skill_level: needed_level
        }).to_a.sample

        # Fallback to any student from same ethnicity if needed
        student_id ||= filter_students(section_data, {
          ethnicity: ethnicity
        }).to_a.sample

        assign_student_to_team(section_data, student_id, team) if student_id
      end
    end
  end

  def pair_remaining_students(section_data, ethnicity)
    unassigned = filter_students(section_data, { ethnicity: ethnicity }).to_a
    return if unassigned.empty?

    while unassigned.size >= 2
      student1_id = unassigned.sample
      student1 = section_data[:students].find { |s| s[:student_id] == student1_id }

      potential_pairs = unassigned - [ student1_id ]
      student2_id = find_matching_pair(section_data, student1, potential_pairs) || potential_pairs.sample

      team = section_data[:teams].max_by { |t| t[:spots_left] }

      if team && team[:spots_left] >= 2
        assign_student_to_team(section_data, student1_id, team)
        assign_student_to_team(section_data, student2_id, team)
      elsif team && team[:spots_left] >= 1
        assign_student_to_team(section_data, student1_id, team)
      end

      unassigned = filter_students(section_data, { ethnicity: ethnicity }).to_a
    end

    # Handle single remaining student
    assign_last_student(section_data, ethnicity) if unassigned.size == 1
  end

  def assign_last_student(section_data, ethnicity)
    student_id = filter_students(section_data, { ethnicity: ethnicity }).to_a.first
    return unless student_id  # No students left

    student = section_data[:students].find { |s| s[:student_id] == student_id }
    return unless student  # Safety check

    # Find teams that already have students from this ethnicity
    eligible_teams = section_data[:teams].select do |team|
      team[:spots_left] > 0 &&
      (team[:composition][:ethnicity][ethnicity] ||= 0) > 0  # Initialize if nil
    end

    # Fallback: if no teams with same ethnicity, take any team with space
    if eligible_teams.empty?
      eligible_teams = section_data[:teams].select { |t| t[:spots_left] > 0 }
    end

    return if eligible_teams.empty?  # No teams available

    # Sort by team size and skill balance
    best_team = eligible_teams.min_by do |team|
      current_members = team[:capacity] - team[:spots_left]
      team_avg = calculate_team_average(section_data, team)
      team_avg_with_student = ((team_avg * current_members) + student[:average]) / (current_members + 1)

      [
        current_members,  # Prefer smaller teams
        (team_avg_with_student - 5.5).abs  # Prefer teams where student helps balance average
      ]
    end

    assign_student_to_team(section_data, student_id, best_team) if best_team
  end
end
