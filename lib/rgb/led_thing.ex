defmodule Rgb.LedThing do
  use Agent

  def start_link() do
    Agent.start_link fn ->
      {:ok, pid} = Rgb.Led.start_link(:nope)
      pid
    end, name: __MODULE__
  end

  def send(msg) do
    Agent.get __MODULE__, fn pid ->
      send(pid, msg)
    end
  end
end
