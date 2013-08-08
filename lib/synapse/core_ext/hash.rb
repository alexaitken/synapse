class Hash
  alias_method :get, :[]
  alias_method :put, :[]=
end
