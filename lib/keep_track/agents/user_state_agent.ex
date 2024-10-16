defmodule KeepTrack.Agents.UserStateAgent do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def update(new_value) do
    Agent.update(__MODULE__, fn _old_value -> new_value end)
  end
end
