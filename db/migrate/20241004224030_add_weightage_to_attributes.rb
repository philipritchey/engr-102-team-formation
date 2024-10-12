class AddWeightageToAttributes < ActiveRecord::Migration[7.2]
  def change
    add_column :attributes, :weightage, :decimal
  end
end
