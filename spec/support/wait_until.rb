module WaitUntil
  def wait_until(t = 1, &block)
    Timeout.timeout(t) do
      loop do
        break if block.call
        sleep 0.01
      end
    end
  end
end

RSpec.configure do |config|
  config.include WaitUntil
end
