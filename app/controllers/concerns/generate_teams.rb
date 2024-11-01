module GenerateTeams
  extend ActiveSupport::Concern

# POST /forms/1/generate_teams
def generate_teams
  ActiveRecord::Base.transaction do
    begin
      # Clear existing teams
      @form.teams.destroy_all

      # Get initial team distribution
      team_distribution = calculate_teams

      # Apply the team formation algorithm pipeline
      # Note that team_distribution is a hash with sections as keys
      team_distribution = populate_teams_based_on_gender(team_distribution)
      team_distribution = optimize_teams_based_on_ethnicity(team_distribution)
      team_distribution = distribute_remaining_students(team_distribution)
      final_team_distribution = optimize_team_by_swaps(team_distribution)

      # Create teams in the database
      final_team_distribution.each do |section, details|
        details[:teams].each_with_index do |team_member_ids, index|
          formatted_members = format_team_members(team_member_ids)
          next if formatted_members.empty?

          @form.teams.create!(
            name: "Team #{index + 1}",
            section: section,
            members: formatted_members
          )
        end
      end

      redirect_to view_teams_form_path(@form), notice: "Teams have been successfully generated!"
    rescue StandardError => e
      Rails.logger.error("Team generation error: #{e.message}\n#{e.backtrace.join("\n")}")
      raise e
    end
  end
end
end
