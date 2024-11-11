module TeamCalculation
  extend ActiveSupport::Concern
  include TeamDistributionHelpers
  def calculate_teams
    # Main orchestrator function
    sections = group_students_by_section
    team_distribution = initialize_team_distribution(sections)
    process_student_data(team_distribution)
    initialize_teams(team_distribution)
    team_distribution
  end

  private

  def group_students_by_section
    # Groups students by section (existing logic)
    @form.form_responses.includes(:student).group_by { |response| response.student.section }
  end

  def initialize_team_distribution(sections)
    # Creates the basic structure for each section
    distribution = {}
    sections.each_key do |section|
      distribution[section] = {
        students: Set.new,
        by_gender: initialize_mcq_sets(get_gender_attribute),
        by_ethnicity: initialize_mcq_sets(get_ethnicity_attribute),
        by_skill: { "low" => Set.new, "medium" => Set.new, "high" => Set.new },
        unassigned: Set.new,
        teams: []
      }
    end
    distribution
  end

  def get_gender_attribute
    gender_attr = @form.form_attributes.where("LOWER(name) = ? AND field_type = ?", "gender".downcase, "mcq").first

    if gender_attr.nil?
      raise "Gender attribute not found in form. Please ensure there is an MCQ attribute named 'gender'."
    end

    if gender_attr.options.blank?
      raise "Gender attribute has no options defined. Please add options (e.g., 'male,female')."
    end

    gender_attr
  end

  def get_ethnicity_attribute
    ethnicity_attr = @form.form_attributes.where("LOWER(name) = ? AND field_type = ?", "ethnicity".downcase, "mcq").first

    if ethnicity_attr.nil?
      raise "Ethnicity attribute not found in form. Please ensure there is an MCQ attribute named 'ethnicity'."
    end

    if ethnicity_attr.options.blank?
      raise "Ethnicity attribute has no options defined. Please add ethnicity options."
    end

    ethnicity_attr
  end

  def initialize_mcq_sets(attribute)
    # Creates sets for each MCQ option
    sets = {}
    attribute.options.split(",").each do |option|
      sets[option.strip] = Set.new
    end
    sets
  end

  def process_student_data(team_distribution)
    # Get attributes once to avoid multiple DB queries
    gender_attribute = get_gender_attribute
    ethnicity_attribute = get_ethnicity_attribute
    scale_attributes = get_scale_attributes

    @form.form_responses.includes(:student).each do |response|
      section = response.student.section

      # Calculate student's data
      student_data = {
        student_id: response.student_id,
        gender: extract_mcq_response(response, gender_attribute) || default_gender,
        ethnicity: extract_mcq_response(response, ethnicity_attribute) || default_ethnicity,
        assigned: false,
        average: calculate_weighted_average(response, scale_attributes),
        team_id: nil
      }

      # Add level based on average
      student_data[:level] = determine_skill_level(student_data[:average])

      # Add to main students set
      team_distribution[section][:students].add(student_data)

      # Add to filtering sets
      student_id = student_data[:student_id]
      team_distribution[section][:by_gender][student_data[:gender]].add(student_id)
      team_distribution[section][:by_ethnicity][student_data[:ethnicity]].add(student_id)
      team_distribution[section][:by_skill][student_data[:level]].add(student_id)
      team_distribution[section][:unassigned].add(student_id)
    end
  end

  def initialize_teams(team_distribution)
    team_distribution.each do |section, data|
      total_students = data[:students].size
      teams_distribution = calculate_team_sizes(total_students)

      # Initialize teams array
      team_id = 1

      # Create teams of 4
      teams_distribution[:teams_of_4].times do
        data[:teams] << create_empty_team(team_id, 4)
        team_id += 1
      end

      # Create teams of 3
      teams_distribution[:teams_of_3].times do
        data[:teams] << create_empty_team(team_id, 3)
        team_id += 1
      end
    end
  end

  def get_scale_attributes
    @form.form_attributes.where(field_type: "scale")
  end

  def extract_mcq_response(response, attribute)
    response.responses[attribute.name]
  end

  def calculate_weighted_average(response, scale_attributes)
    total_weight = 0
    weighted_sum = 0

    scale_attributes.each do |attribute|
      value = response.responses[attribute.name].to_f
      weight = attribute.weightage || 0

      weighted_sum += value * weight
      total_weight += weight
    end

    return 5.5 if total_weight.zero? # Default middle value
    (weighted_sum / total_weight).round(2)
  end

  def determine_skill_level(average)
    case
    when average < 4 then "low"
    when average < 7 then "medium"
    else "high"
    end
  end

  def calculate_team_sizes(total_students)
    base_teams = total_students / 4
    remainder = total_students % 4

    teams_of_4 = case remainder
    when 0 then base_teams
    when 1 then base_teams - 2
    when 2 then base_teams - 1
    when 3 then base_teams
    end

    teams_of_3 = remainder.zero? ? 0 : 4 - remainder

    { teams_of_4: teams_of_4, teams_of_3: teams_of_3 }
  end

  def create_empty_team(team_id, capacity)
    {
      team_id: team_id,
      capacity: capacity,
      members: Array.new(capacity, 0),
      composition: {
        gender: Hash.new(0),
        ethnicity: Hash.new(0),
        skill: Hash.new(0)
      },
      spots_left: capacity
    }
  end

  def default_gender
    get_gender_attribute.options.split(",").first.strip
  end

  def default_ethnicity
    get_ethnicity_attribute.options.split(",").first.strip
  end
end
