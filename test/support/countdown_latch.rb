class CountdownLatch
  def initialize(count)
    @count = count
    @mutex = Mutex.new
  end

  def countdown!
    @mutex.synchronize do
      @count = @count.pred if @count > 0
    end
  end

  def count
    @mutex.synchronize do
      @count
    end
  end
end
