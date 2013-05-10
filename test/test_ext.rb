class Test::Unit::TestCase
  # Blocks until a condition is met or a timeout occurs
  #
  # @param [Integer] timeout In seconds
  # @param [Float] retry_interval In seconds
  # @return [undefined]
  def wait_until(timeout = 2, retry_interval = 0.1, &block)
    start = Time.now
    until !!block.call
      raise if (Time.now - start).to_i >= timeout
      sleep retry_interval
    end
  end
end
