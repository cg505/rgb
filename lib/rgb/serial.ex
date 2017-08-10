defmodule Rgb.Serial do
  use Agent

  def start_link() do
    {tty, _} =
      Nerves.UART.enumerate()
      |> Enum.find(:error, fn{_, v} -> v[:vendor_id] == 9025 end)

    {:ok, pid} = Nerves.UART.start_link
    :ok = Nerves.UART.open(pid, tty, active: false)
    IO.puts "starting this shit"
    Agent.start_link fn ->
      IO.puts "inside startlink"
      {pid, 0}
    end, name: __MODULE__
  end

  def reset(force \\ false) do
    Agent.update __MODULE__, fn {pid, count} ->
      if force || count > 10 do
        Nerves.UART.write(pid, [0, 0, 0, 0, 0, 1])
        {pid, 0}
      else
        {pid, count}
      end
    end
  end

  def write(red, green, blue) do
    array = if((red == 0 && green == 0 && blue == 0), do: [0, 0, 0, 1], else: [red, green, blue])
    if Enum.all?(array, fn x -> x in 0..255 end) do
      Agent.update __MODULE__, fn {pid, count} ->
        if count > 10 do
          Nerves.UART.write(pid, [0, 0, 0, 0, 0, 1])
        end
        Nerves.UART.read(pid)
        Nerves.UART.write(pid, array)
        {pid, if(count > 10, do: 1, else: count + 1)}
      end
    else
      {:error, :out_of_range}
    end
  end
end
