module WaitHelper
  TimeoutError = Class.new RuntimeError

  def wait_until(timeout = 5, cycles = 10_000, &block)
    start = Time.now

    until block.call
      elapsed = Time.now - start
      raise TimeoutError unless elapsed < timeout

      cycles.times do
        # Busy spin for awhile and check again
      end
    end
  end
end
