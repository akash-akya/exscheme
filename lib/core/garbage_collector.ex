defmodule Exscheme.Core.GarbageCollector do
  alias Exscheme.Core.Environment, as: Env
  alias Exscheme.Core.Procedure

  def garbage_collect(%Env{frame_map: frames} = env, value) do
    visited =
      Enum.reduce(env.callstack, MapSet.new(), fn id, visited ->
        visit(id, frames, visited)
      end)

    visited = traverse_value(value, frames, visited)

    frames = Map.take(frames, MapSet.to_list(visited))
    %Env{env | frame_map: frames}
  end

  defp visit(id, frames, visited) do
    visited = MapSet.put(visited, id)
    visited = visit_parents(frames[id].parent, frames, visited)

    Enum.reduce(frames[id].data, visited, fn
      {_, value}, visited -> traverse_value(value, frames, visited)
    end)
  end

  defp traverse_value([], frames, visited), do: visited

  defp traverse_value([value | rest], frames, visited) do
    traverse_value(rest, frames, traverse_value(value, frames, visited))
  end

  defp traverse_value(%Procedure{current_frame: frame}, frames, visited) do
    if !MapSet.member?(visited, frame) do
      visit(frame, frames, visited)
    else
      visited
    end
  end

  defp traverse_value(_, _, visited), do: visited

  defp visit_parents(nil, _, visited), do: visited

  defp visit_parents(id, frames, visited) do
    if !MapSet.member?(visited, id) do
      visit_parents(frames[id].parent, frames, MapSet.put(visited, id))
    else
      visited
    end
  end
end
