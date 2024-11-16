module TeamDistributionHelpers
  extend ActiveSupport::Concern

  private

  def filter_students(section_data, criteria = {})
    student_ids = section_data[:unassigned].clone

    if criteria[:gender]
      student_ids &= section_data[:by_gender][criteria[:gender]]
    end

    if criteria[:ethnicity]
      student_ids &= section_data[:by_ethnicity][criteria[:ethnicity]]
    end

    if criteria[:skill_level]
      student_ids &= section_data[:by_skill][criteria[:skill_level]]
    end

    student_ids
  end

  def assign_student_to_team(section_data, student_id, team)
    student = section_data[:students].find { |s| s[:student_id] == student_id }
    return false unless student

    student[:assigned] = true
    student[:team_id] = team[:team_id]

    empty_spot_index = team[:members].find_index(0)
    return false unless empty_spot_index

    team[:members][empty_spot_index] = student_id
    team[:spots_left] -= 1

    team[:composition][:gender][student[:gender]] += 1
    team[:composition][:ethnicity][student[:ethnicity]] += 1
    team[:composition][:skill][student[:level]] += 1

    section_data[:unassigned].delete(student_id)

    true
  end

  def calculate_team_average(section_data, team)
    total = 0.0
    count = 0

    team[:members].each do |member_id|
      next if member_id == 0
      student = section_data[:students].find { |s| s[:student_id] == member_id }
      total += student[:average]
      count += 1
    end

    count > 0 ? total / count : 0
  end

  def determine_needed_skill_level(current_avg)
    if current_avg < 4
      "high"
    elsif current_avg > 7
      "low"
    else
      "medium"
    end
  end


  # Finds a matching student pair based on skill level compatibility
  # @param section_data [Hash] Section information
  # @param student1 [Hash] The first student's information
  # @param potential_pairs [Array] Array of potential partner student IDs
  # @return [Integer, nil] ID of the matching student or nil if no match found
  def find_matching_pair(section_data, student1, potential_pairs)
    preferred_levels = case student1[:level]
    when "low"
      [ "high", "medium" ]
    when "high"
      [ "low", "medium" ]
    else # medium
      [ "medium", "low", "high" ] # Added fallback levels for medium skill students
    end

    find_student_by_levels(section_data, potential_pairs, preferred_levels)
  end

  # Helper method to find a student by preferred skill levels
  # @param section_data [Hash] Section information
  # @param potential_pairs [Array] Array of potential student IDs
  # @param preferred_levels [Array] Ordered array of preferred skill levels
  # @return [Integer, nil] ID of the first matching student or nil
  private def find_student_by_levels(section_data, potential_pairs, preferred_levels)
    preferred_levels.each do |level|
      match = potential_pairs.find { |id| get_student_level(section_data, id) == level }
      return match if match
    end
    nil
  end

  def get_student_level(section_data, student_id)
    student = section_data[:students].find { |s| s[:student_id] == student_id }
    student[:level]
  end
end
