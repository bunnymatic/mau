# frozen_string_literal: true

require_relative '../../spec/support/test_es_server'
require_relative './webmock'

AfterConfiguration do
  TestEsServer.start
end

at_exit do
  TestEsServer.stop
end
