class AddUserAssociationToForms < ActiveRecord::Migration[7.2]
  def up
    # Add foreign key if it doesn't exist
    add_column :forms, :user_id, :integer
    unless foreign_key_exists?(:forms, :users)
      add_foreign_key :forms, :users
    end

    # Handle existing records
    Form.where(user_id: nil).find_each do |form|
      if User.exists?
        form.update(user_id: User.first.id)
      else
        form.destroy
      end
    end

    # Ensure user_id is not null for future records
    change_column_null :forms, :user_id, false
  end

  def down
    # Remove the foreign key
    remove_foreign_key :forms, :users if foreign_key_exists?(:forms, :users)

    # Allow null values for user_id
    change_column_null :forms, :user_id, true
  end
end
