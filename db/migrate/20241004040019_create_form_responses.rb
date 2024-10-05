class CreateFormResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :form_responses do |t|
      t.string :uin, null: false, primary_key: true
      t.references :form, null: false, foreign_key: true
      t.text :responses, null: false, default: '{}'
      t.timestamps
    end
  end
end
