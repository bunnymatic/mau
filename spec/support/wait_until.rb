module WaitUntil
  def wait_until(time = 1)
    Timeout.timeout(time) do
      loop do
        break if yield

        sleep 0.1
      end
    end
  end
end

RSpec.configure do |config|
  config.include WaitUntil
end
