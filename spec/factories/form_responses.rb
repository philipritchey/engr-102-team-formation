FactoryBot.define do
    factory :form_response do
      form
      student
      responses { { "question1" => "answer1", "question2" => "answer2" } }
    end
end
