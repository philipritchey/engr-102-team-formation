class ModifyUsersTable < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    remove_column :users, :created_at, :string
    remove_column :users, :updated_at, :string

    add_column :users, :uin, :string
  end
end
