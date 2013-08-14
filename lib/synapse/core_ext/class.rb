class Class
  # @param [Symbol...] syms
  # @return [undefined]
  def inherit_reader(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def self.#{sym}
          unless @#{sym}
            if superclass.respond_to? :#{sym}
              @#{sym} = superclass.#{sym}.clone
            end
          end

          @#{sym}
        end
      RUBY_EVAL

      unless options[:instance_reader] == false || options[:instance_accessor] == false
        class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{sym}
            self.class.#{sym}
          end
        RUBY_EVAL
      end
    end
  end

  # @yield
  # @param [Symbol...] syms
  # @return [undefined]
  def inherit_writer(*syms, &block)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def self.#{sym}=(value)
          @#{sym} = value
        end
      RUBY_EVAL

      unless options[:instance_writer] == false || options[:instance_accessor] == false
        class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{sym}=(value)
            self.class.#{sym} = value
          end
        RUBY_EVAL
      end

      send("#{sym}=", yield) if block_given?
    end
  end

  # @yield
  # @param [Symbol...] syms
  # @return [undefined]
  def inherit_accessor(*syms, &block)
    inherit_reader *syms
    inherit_writer *syms, &block
  end
end
