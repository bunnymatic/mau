require 'rails_helper'

describe ContactArtistAboutArtFormData do
  describe 'validations' do
    it 'requires either phone or email' do
      expect(subject).not_to be_valid
      expect(subject.errors['phone']).to include 'You must include either email or phone or both'
      expect(subject.errors['email']).to include 'You must include either email or phone or both'
    end
    it { is_expected.to validate_presence_of(:art_piece_id) }
    it { is_expected.to validate_presence_of(:name) }
    it 'requires email looks like an email' do
      form_data = described_class.new({ email: 'whatever' })
      expect(form_data).not_to be_valid
      expect(form_data.errors['email']).to include 'should look like an email address.'
    end
    it 'requires phone looks like an phone' do
      form_data = described_class.new({ phone: '12321' })
      expect(form_data).not_to be_valid
      expect(form_data.errors['phone']).to include 'must be 10 or 11 digits'
    end
    it 'is valid with only phone and not email' do
      form_data = described_class.new({ name: 'Joe', phone: '2325551212', art_piece_id: 1 })
      expect(form_data).to be_valid
    end
  end
end
