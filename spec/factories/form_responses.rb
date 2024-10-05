FactoryBot.define do
    factory :form_response do
      association :form
      uin { "123456789" }
      responses { {} }
    end
end
