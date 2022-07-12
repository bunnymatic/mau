require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:active_notification) { create :notification, activated_at: Time.zone.yesterday }
  let(:not_active_notifications) do
    [
      create(:notification, activated_at: Time.zone.tomorrow),
      create(:notification),
    ]
  end
  let(:notifications) { [active_notification, not_active_notifications].flatten }

  describe 'scopes' do
    before do
      notifications
    end

    describe 'active' do
      it 'includes only active notifications' do
        expect(Notification.all).to have(3).notifications
        expect(Notification.active).to eq [active_notification]
      end
    end
  end
end
