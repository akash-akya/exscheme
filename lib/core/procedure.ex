defmodule Exscheme.Core.Procedure do
  defstruct [:params, :body, :env]

  def new(params, body, env) do
    %__MODULE__{
      params: params,
      body: body,
      env: hd(env.stack)
    }
  end
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Procedure do
  def to_native(proc, _memory), do: "#<LAMBDA::#{inspect(proc)}>"
end
