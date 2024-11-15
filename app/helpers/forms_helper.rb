module FormsHelper
  # def validate_header(header_row)
  #   if header_row.nil? || header_row.all?(&:blank?)
  #     flash[:alert] = "The first row is empty. Please provide column names."
  #     return false # Indicate failure
  #   end

  #   name_index = header_row.index("Name") || -1
  #   uin_index = header_row.index("UIN") || -1
  #   email_index = header_row.index("Email ID") || -1
  #   section_index = header_row.index("Section") || -1

  #   puts name_index, uin_index, email_index, section_index

  #   unless name_index >= 0 && uin_index >= 0 && email_index >= 0 && section_index >= 0
  #     flash[:alert] = "Missing required columns. Ensure 'Name', 'UIN', 'Section' and 'Email ID' are present."
  #     return false # Indicate failure
  #   end

  #   [ name_index, uin_index, email_index, section_index ] # Return indices if validation passes
  # end
  #
  def validate_header(header_row)
    # Check if the header row is nil or blank
    if header_row.nil? || header_row.all?(&:blank?)
      flash[:alert] = "The first row is empty. Please provide column names."
      return false # Indicate failure
    end

    # Required headers for the file
    required_headers = [ "Name", "UIN", "Email ID", "Section" ]

    # Map required headers to their indices
    header_indexes = required_headers.map { |header| header_row.index(header) }

    # Check if any required header is missing
    if header_indexes.any?(&:nil?)
      # missing_headers = required_headers.select.with_index { |_header, index| header_indexes[index].nil? }
      # flash[:alert] = "Missing required columns: #{missing_headers.join(', ')}."
      return false # Indicate failure
    end

    # Return indices if all headers are found
    header_indexes
  end

  def validate_row(row, index, header_row, column_indexes)
    name_index, uin_index, email_index, section_index = column_indexes

    # Extract values from the row and convert to strings where necessary
    name = row[name_index].to_s.strip unless row[name_index].nil?
    uin = row[uin_index].to_s.strip unless row[uin_index].nil?
    email = row[email_index].to_s.strip unless row[email_index].nil?
    section = row[section_index].to_s.strip unless row[section_index].nil?

    # Validate presence and format for required fields
    if name.blank?
      flash[:alert] = "Missing value in 'Name' column for row #{index}."
      return nil
    end

    if uin.blank? || uin.match(/\A\d{9}\z/).nil?
      flash[:alert] = "Invalid UIN in 'UIN' column for row #{index}. It must be a 9-digit number."
      return nil
    end

    if email.blank? || !email.match(/\A[^@\s]+@[^@\s]+\z/)
      flash[:alert] = "Invalid email in 'Email ID' column for row #{index}."
      return nil
    end

    # Build the user data hash
    {
      name: name,
      uin: uin,
      email: email,
      section: section,
      created_at: Time.now,
      updated_at: Time.now
    }
  end



  def valid_uin?(uin_value)
    uin_value.is_a?(String) && uin_value.match?(/^\d{9}$/)
  end

  def valid_email?(email_value)
    email_value =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  end
end
