defmodule Rgb.Serial do
  use Agent

  def start_link() do
    {tty, _} =
      Nerves.UART.enumerate()
      |> Enum.find(:error, fn{_, v} -> v[:vendor_id] == 9025 end)

    Agent.start_link fn ->
      {:ok, pid} = Nerves.UART.start_link
      :ok = Nerves.UART.open(pid, tty, active: false)
      pid
    end, name: __MODULE__
  end

  def try_write(pid, count, red, green, blue) do
    # if we've tried more than 5 times just give up
    unless count > 5 do
      # clear out any lingering output
      Nerves.UART.read(pid, 0)
      Nerves.UART.write(pid, [0, 1, red, green, blue, 1, red, green, blue])
      {:ok, read} = Nerves.UART.read(pid, 15)
      unless (read == <<rem(red + green + blue, 256)>>) do
        # flush any possible current state
        Nerves.UART.write(pid, [0, 0, 0, 0])
        try_write(pid, count + 1, red, green, blue)
      end
    end
  end

  def write(red, green, blue) do
    if Enum.all?([red, green, blue], fn x -> x in 0..255 end) do
      Agent.update __MODULE__, fn pid ->
        try_write(pid, 0, red, green, blue)
        pid
      end
    else
      {:error, :out_of_range}
    end
  end
end
