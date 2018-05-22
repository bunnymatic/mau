# frozen_string_literal: true

require_relative '../../spec/support/test_es_server'
require_relative './webmock'

AfterConfiguration do
  TestEsServer.start unless ENV['CI']
end

at_exit do
  TestEsServer.stop unless ENV['CI']
end
