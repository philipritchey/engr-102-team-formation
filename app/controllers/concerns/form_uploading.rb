module FormUploading
  extend ActiveSupport::Concern
  include FormsHelper

  def upload
    @form = Form.find(params[:id])
  end

  def validate_upload
    if params[:file].present?
      process_uploaded_file
    else
      flash[:alert] = "Please upload a file."
      redirect_to form_path(params[:id])
    end
  end

  def download_sample
    # Specify the path to your sample CSV file
    file_path = Rails.root.join("spec/fixtures/files", "valid_file.csv")

    # Send the file to the user
    send_file file_path, filename: "valid_file.csv", type: "text/csv"
  end

  private

  def process_uploaded_file
    file = params[:file].path
    begin
      spreadsheet = Roo::Spreadsheet.open(file)
      process_spreadsheet(spreadsheet)
    rescue StandardError => e
      flash[:alert] = "An error occurred: #{e.message}"
      redirect_to form_path(params[:id])
    end
  end

  def process_spreadsheet(spreadsheet)
    header_row = spreadsheet.row(1)

    if header_row.nil? || header_row.all?(&:blank?)
      flash[:alert] = "The first row is empty. Please provide column names."
      redirect_to form_path(params[:id]) and return
    end

    process_user_data(spreadsheet, header_row)
  end

  def process_user_data(spreadsheet, header_row)
    users_to_create = []
    name_index, uin_index, email_index, section_index = validate_header(header_row)
    (2..spreadsheet.last_row).each do |index|
      row = spreadsheet.row(index)
      user_data = validate_row(row, index, header_row, [ name_index, uin_index, email_index, section_index ])
      return redirect_to form_path(params[:id]) if user_data.nil?
      users_to_create << user_data
    end

    create_students_and_responses(users_to_create)
    flash[:notice] = "All validations passed."
    redirect_to form_path(params[:id])
  end

  def create_students_and_responses(users_to_create)
    Student.upsert_all(users_to_create, unique_by: :uin)
    student_ids = users_to_create.map { |student| Student.find_by(uin: student[:uin])&.id }.compact
    existing_student_ids = FormResponse.where(form_id: params[:id]).pluck(:student_id)

    form_responses_to_create = student_ids
      .reject { |id| existing_student_ids.include?(id) }
      .map do |student_id|
        {
          student_id: student_id,
          form_id: params[:id],
          responses: {}.to_json
        }
      end

    FormResponse.insert_all(form_responses_to_create) if form_responses_to_create.any?
  end
end
