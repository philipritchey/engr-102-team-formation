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

  # Identifies and handles students who are the only ones of their ethnicity in a team
  # @param section_data [Hash] Contains all section information including teams and students
  # @param ethnicity [String] The ethnicity being processed
  def handle_isolated_students(section_data, ethnicity)
    find_teams_with_isolated_students(section_data, ethnicity).each do |team|
      process_isolated_student(section_data, team, ethnicity)
    end
  end

  # Finds teams that have isolated students of the given ethnicity
  # @param section_data [Hash] Section information
  # @param ethnicity [String] The ethnicity to check
  # @return [Array<Hash>] Array of teams with isolated students
  def find_teams_with_isolated_students(section_data, ethnicity)
    section_data[:teams].select do |team|
      should_handle_isolated_student?(team, ethnicity)
    end
  end

  # Processes a single isolated student case
  # @param section_data [Hash] Section information
  # @param team [Hash] The team with the isolated student
  # @param ethnicity [String] The ethnicity being processed
  def process_isolated_student(section_data, team, ethnicity)
    student_id = find_matching_student_for_isolated(section_data, team, ethnicity)
    assign_student_to_team(section_data, student_id, team) if student_id
  end

  # Determines if a team has exactly one student of the given ethnicity and has space for more
  # @param team [Hash] The team to check
  # @param ethnicity [String] The ethnicity to check for
  # @return [Boolean] True if the team has one isolated student and space for more
  def should_handle_isolated_student?(team, ethnicity)
    team[:composition][:ethnicity][ethnicity] ||= 0
    team[:composition][:ethnicity][ethnicity] == 1 && team[:spots_left] > 0
  end

  # Finds a suitable student to pair with an isolated student
  # First attempts to find a student with matching skill level
  # Falls back to any student of the same ethnicity if no skill match is found
  # @param section_data [Hash] Section information
  # @param team [Hash] The team with the isolated student
  # @param ethnicity [String] The ethnicity to match
  # @return [Integer, nil] The ID of a matching student, or nil if none found
  def find_matching_student_for_isolated(section_data, team, ethnicity)
    current_avg = calculate_team_average(section_data, team)
    needed_level = determine_needed_skill_level(current_avg)

    # Try to find student with matching skill level
    student_id = filter_students(section_data, {
      ethnicity: ethnicity,
      skill_level: needed_level
    }).to_a.sample

    # Fallback to any student from same ethnicity
    student_id ||= filter_students(section_data, { ethnicity: ethnicity }).to_a.sample
  end

  # Processes remaining unassigned students of a specific ethnicity
  # Attempts to pair them together when possible
  # Handles any single remaining student separately
  # @param section_data [Hash] Section information
  # @param ethnicity [String] The ethnicity being processed
  def pair_remaining_students(section_data, ethnicity)
    unassigned = filter_students(section_data, { ethnicity: ethnicity }).to_a
    return if unassigned.empty?

    while unassigned.size >= 2
      student_pair = select_student_pair(section_data, unassigned)
      assign_student_pair(section_data, student_pair) if student_pair

      # Refresh unassigned list after assignments
      unassigned = filter_students(section_data, { ethnicity: ethnicity }).to_a
    end

    # Handle any remaining single student
    assign_last_student(section_data, ethnicity) if unassigned.size == 1
  end

  # Selects two students to form a pair, attempting to match skill levels
  # @param section_data [Hash] Section information
  # @param unassigned [Array] List of unassigned student IDs
  # @return [Array] Array containing two student IDs
  def select_student_pair(section_data, unassigned)
    student1_id = unassigned.sample
    student1 = section_data[:students].find { |s| s[:student_id] == student1_id }

    potential_pairs = unassigned - [ student1_id ]
    student2_id = find_matching_pair(section_data, student1, potential_pairs) || potential_pairs.sample

    [ student1_id, student2_id ]
  end

  # Assigns a pair of students to the team with the most available spots
  # If there's only one spot left, assigns only the first student
  # @param section_data [Hash] Section information
  # @param student_pair [Array] Array of two student IDs to assign
  def assign_student_pair(section_data, student_pair)
    team = section_data[:teams].max_by { |t| t[:spots_left] }
    return unless team

    if team[:spots_left] >= 2
      student_pair.each { |student_id| assign_student_to_team(section_data, student_id, team) }
    elsif team[:spots_left] >= 1
      assign_student_to_team(section_data, student_pair.first, team)
    end
  end

  # Handles assignment of a single remaining student
  # Finds the most suitable team based on existing ethnic composition and team balance
  # @param section_data [Hash] Section information
  # @param ethnicity [String] The ethnicity of the student
  def assign_last_student(section_data, ethnicity)
    student_id = filter_students(section_data, { ethnicity: ethnicity }).to_a.first
    return unless student_id

    student = section_data[:students].find { |s| s[:student_id] == student_id }
    return unless student

    best_team = find_best_team_for_last_student(section_data, student, ethnicity)
    assign_student_to_team(section_data, student_id, best_team) if best_team
  end

  # Finds the optimal team for the last remaining student
  # Considers both team composition and skill level balance
  # @param section_data [Hash] Section information
  # @param student [Hash] Student information
  # @param ethnicity [String] Student's ethnicity
  # @return [Hash, nil] The best matching team or nil if none found
  def find_best_team_for_last_student(section_data, student, ethnicity)
    eligible_teams = find_eligible_teams(section_data, ethnicity)
    return if eligible_teams.empty?

    eligible_teams.min_by do |team|
      calculate_team_score(team, student, section_data)
    end
  end

  # Finds teams that are eligible for receiving the last student
  # Prioritizes teams that already have students of the same ethnicity
  # Falls back to any team with available spots if necessary
  # @param section_data [Hash] Section information
  # @param ethnicity [String] Student's ethnicity
  # @return [Array] List of eligible teams
  def find_eligible_teams(section_data, ethnicity)
    # Try teams with same ethnicity first
    teams = section_data[:teams].select do |team|
      team[:spots_left] > 0 &&
      (team[:composition][:ethnicity][ethnicity] ||= 0) > 0
    end

    # Fallback to any team with space
    teams.empty? ? section_data[:teams].select { |t| t[:spots_left] > 0 } : teams
  end

  # Calculates a score for how well a student fits into a team
  # Lower scores indicate better fits
  # Considers both team size and skill level balance
  # @param team [Hash] Team information
  # @param student [Hash] Student information
  # @param section_data [Hash] Section information
  # @return [Array] Score components [team_size, skill_balance_score]
  def calculate_team_score(team, student, section_data)
    current_members = team[:capacity] - team[:spots_left]
    team_avg = calculate_team_average(section_data, team)
    team_avg_with_student = ((team_avg * current_members) + student[:average]) / (current_members + 1)

    [
      current_members,
      (team_avg_with_student - 5.5).abs  # 5.5 is the target average
    ]
  end
end
