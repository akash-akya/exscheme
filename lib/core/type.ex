defprotocol Exscheme.Core.Type do
  def to_native(value, memory)
  def collect(value, memory, visited)
end
