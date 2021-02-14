require 'rails_helper'

describe ServerStatus, vcr: { cassette_name: 'server_status', record: :none } do
  describe '.run' do
    subject(:run_status) { described_class.run }
    it 'returns the status of the server' do
      expect(subject).to eql(
        version: Mau::Version::VERSION,
        main: true,
        elasticsearch: true,
      )
    end
  end
end
