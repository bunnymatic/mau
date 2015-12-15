require_relative "../../spec/support/test_es_server"

Before("@elasticsearch") do
  TestEsServer.start
end

After("@elasticsearch") do
  TestEsServer.stop
end
