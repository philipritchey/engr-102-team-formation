class ModifyUsersTable1 < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :last_name, :string
  end
end
