class Test
  def herp(t)
    t.derp
  end
  
protected
  
  def derp
    puts 'doing derpy things'
  end
end

t1 = Test.new
t2 = Test.new

t1.herp(t2)
