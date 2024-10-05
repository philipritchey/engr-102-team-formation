class AddDeadlineToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :deadline, :datetime
  end
end
