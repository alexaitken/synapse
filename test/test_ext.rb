class Test::Unit::TestCase
  # Blocks until a condition is met or a timeout occurs
  #
  # @param [Integer] timeout In seconds
  # @param [Float] retry_interval In seconds
  # @return [undefined]
  def wait_until(timeout = 5, retry_interval = 0.01, &block)
    start = Time.now
    until !!block.call
      if (Time.now - start).to_i >= timeout
        raise 'Operation timed out'
      end

      sleep retry_interval
    end
  end
end
