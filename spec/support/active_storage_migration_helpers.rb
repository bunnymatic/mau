require_relative 'test_es_server'

RSpec.configure do |config|
  config.before do |example|
    case example.metadata[:mock_duplicate_active_storage]
    when true
      allow_any_instance_of(ArtPiece).to receive(:duplicate_active_storage)
      allow_any_instance_of(Artist).to receive(:duplicate_active_storage)
      allow_any_instance_of(User).to receive(:duplicate_active_storage)
      allow_any_instance_of(Studio).to receive(:duplicate_active_storage)
    end
  end
end
