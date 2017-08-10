defmodule Rgb.Led do
  use Task

  @priority [
    :custom,
    # :calendar,
    :default,
  ]

  @default_timeout 500

  def start_link(_arg) do
    Task.start_link(__MODULE__, :loop, [:default, 0])
  end

  # def child_spec(_args) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :loop, [:default, 0]}
  #   }
  # end

  def handle_in({:static, %{red: red, green: green, blue: blue}}) do
    {:custom, static: %{red: red, green: green, blue: blue}}
  end

  def handle_in(:fade) do
    {:custom, fade: 0}
  end

  def handle_in(:unset) do
    updates(:default)
  end

  def updates(state) do
    updates(state, @priority)
  end

  def updates(state, [:custom | rest]) do
    case state do
      {:custom, _} -> state
      _ -> updates(state, rest)
    end
  end

  def updates(_state, [:default | _]) do
    :default
  end

  def loop(state, timeout) do
    next_state = receive do
      inst -> handle_in(inst)
    after
      timeout -> updates(state)
    end

    IO.puts("next state")
    IO.inspect(next_state)

    light(next_state)
  end

  def light(:default) do
    Rgb.Serial.write(0, 255, 0)
    loop(:default, @default_timeout)
  end

  def light({:custom, static: %{red: red, green: green, blue: blue}} = state) do
    Rgb.Serial.write(red, green, blue)
    loop(state, @default_timeout)
  end

  # t  0   255 510 765 020 275
  # r  255 255 0   0   0   255
  # g  0   255 255 255 0   0
  # b  0   0   0   255 255 255
  def light({:custom, fade: time}) do
    cond do
      time in 0..254 -> Rgb.Serial.write(255, time, 0)
      time in 255..509 -> Rgb.Serial.write(510 - time, 255, 0)
      time in 510..764 -> Rgb.Serial.write(0, 255, time - 510)
      time in 765..1019 -> Rgb.Serial.write(0, 1020 - time, 255)
      time in 1020..1274 -> Rgb.Serial.write(time - 1020, 0, 255)
      time in 1275..1349 -> Rgb.Serial.write(255, 0, 1350 - time)
    end
    loop({:custom, fade: rem((time + 1), 1350)}, 25)
  end
end
