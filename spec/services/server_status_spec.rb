require 'rails_helper'

describe ServerStatus, vcr: { cassette_name: 'server_status', record: :none } do
  before do
    VCR.configure do |c|
      c.unignore_hosts '127.0.0.1', 'localhost'
    end
  end
  after do
    VCR.configure do |c|
      c.ignore_localhost = true
    end
  end
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
