defmodule Exscheme.Core.Procedure do
  defstruct params: nil, body: nil, env: nil

  def new(params, body, env) do
    %__MODULE__{
      params: params,
      body: body,
      env: env.frames
    }
  end
end
