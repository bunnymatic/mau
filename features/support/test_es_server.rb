require_relative "../../spec/support/test_es_server"
require_relative "./webmock"

TestEsServer.start

at_exit do
  TestEsServer.stop
end
