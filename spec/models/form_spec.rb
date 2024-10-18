require 'rails_helper'

RSpec.describe Form, type: :model do
  let(:user) { create(:user) }
  let(:form) { create(:form, user: user) }

  describe 'associations' do
    it 'belongs to a user' do
      expect(form.user).to eq(user)
    end

    it 'has many form attributes' do
      attribute = create(:attribute, form: form)
      expect(form.form_attributes).to include(attribute)
    end

    it 'destroys associated form attributes when destroyed' do
      attribute = create(:attribute, form: form)
      expect { form.destroy }.to change(Attribute, :count).by(-1)
    end

    it 'has many form responses' do
      response = create(:form_response, form: form)
      expect(form.form_responses).to include(response)
    end

    it 'has many students through form responses' do
      student = create(:student)
      create(:form_response, form: form, student: student)
      expect(form.students).to include(student)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(form).to be_valid
    end

    it 'is not valid without a name' do
      form.name = nil
      expect(form).not_to be_valid
    end

    it 'is not valid with a duplicate name' do
      create(:form, name: 'Test Form')
      form.name = 'Test Form'
      expect(form).not_to be_valid
    end

    it 'is not valid without a description' do
      form.description = nil
      expect(form).not_to be_valid
    end
  end

  describe '#has_attributes?' do
    it 'returns true when form has attributes' do
      create(:attribute, form: form)
      expect(form.has_attributes?).to be true
    end

    it 'returns false when form has no attributes' do
      expect(form.has_attributes?).to be false
    end
  end

  describe '#has_associated_students?' do
    context 'when form has associated students' do
      before { create(:form_response, form: form) }
      it 'returns true' do
        expect(form.has_associated_students?).to be true
      end
    end

    context 'when form has no associated students' do
      it 'returns false' do
        expect(form.has_associated_students?).to be false
      end
    end
  end

  describe '#can_publish?' do
    context 'when form has attributes and associated students' do
      before do
        create(:attribute, form: form)
        create(:form_response, form: form)
      end
      it 'returns true' do
        expect(form.can_publish?).to be true
      end
    end

    context 'when form has attributes but no associated students' do
      before { create(:attribute, form: form) }
      it 'returns false' do
        expect(form.can_publish?).to be false
      end
    end

    context 'when form has associated students but no attributes' do
      before { create(:form_response, form: form) }
      it 'returns false' do
        expect(form.can_publish?).to be false
      end
    end

    context 'when form has neither attributes nor associated students' do
      it 'returns false' do
        expect(form.can_publish?).to be false
      end
    end
  end

  describe 'deadline validation' do
    context 'when deadline is in the past' do
      it 'is not valid' do
        form = build(:form, deadline: 1.day.ago)
        expect(form).not_to be_valid
        expect(form.errors[:deadline]).to include("cannot be in the past")
      end
    end

    context 'when deadline is in the future' do
      it 'is valid' do
        form = build(:form, deadline: 1.day.from_now)
        expect(form).to be_valid
      end
    end
  end
end
