class Array
  # Taken from ActiveSupport
  # @return [Hash]
  def extract_options!
    # :nocov:
    if last.is_a? Hash
      pop
    else
      {}
    end
    # :nocov:
  end unless method_defined? :extract_options!
end
