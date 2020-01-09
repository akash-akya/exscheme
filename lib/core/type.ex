defprotocol Exscheme.Core.Type do
  def to_native(value, memory)
end
