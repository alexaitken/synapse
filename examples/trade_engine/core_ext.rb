# Monkey-patched because the sorted set apparently doesn't have a way for you to
# access the first or last sorted element. wtf ruby?
#
# Note: this is probably sooper slow.
class SortedSet
  def first
    to_a[0]
  end

  def last
    to_a[length - 1]
  end
end
