defmodule Exscheme.Core.Procedure do
  defstruct params: nil, body: nil, current_frame: nil

  def new(params, body, current_frame) do
    %__MODULE__{
      params: params,
      body: body,
      current_frame: current_frame
    }
  end
end
