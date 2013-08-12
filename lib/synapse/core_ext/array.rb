class Array
  # @return [Hash]
  def extract_options!
    if last.is_a? Hash
      pop
    else
      {}
    end
  end unless method_defined? :extract_options!
end
