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

  def find_matching_pair(section_data, student1, potential_pairs)
    student1_level = student1[:level]

    case student1_level
    when "low"
      # Try to find high, then medium
      high_skill = potential_pairs.find { |id| get_student_level(section_data, id) == "high" }
      return high_skill if high_skill

      medium_skill = potential_pairs.find { |id| get_student_level(section_data, id) == "medium" }
      return medium_skill if medium_skill
    when "high"
      # Try to find low, then medium
      low_skill = potential_pairs.find { |id| get_student_level(section_data, id) == "low" }
      return low_skill if low_skill

      medium_skill = potential_pairs.find { |id| get_student_level(section_data, id) == "medium" }
      return medium_skill if medium_skill
    else # medium
      # Try to find another medium
      medium_skill = potential_pairs.find { |id| get_student_level(section_data, id) == "medium" }
      return medium_skill if medium_skill
    end

    nil
  end

  def get_student_level(section_data, student_id)
    student = section_data[:students].find { |s| s[:student_id] == student_id }
    student[:level]
  end
end
