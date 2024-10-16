class UpdateFormResponsesWithStudentId < ActiveRecord::Migration[7.2]
  def change
    add_reference :form_responses, :student, null: false, foreign_key: true
    remove_column :form_responses, :uin, :string
    add_index :form_responses, [:student_id, :form_id], unique: true
  end
end
