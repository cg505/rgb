defmodule RgbWeb.ApiController do
  use RgbWeb, :controller

  def index(conn, _params) do
    json conn, %{name: "Christopher", age: 19}
  end

  def post(conn, %{"red" => red, "green" => green, "blue" => blue}) do
    Rgb.LedThing.send({:static, %{red: red, green: green, blue: blue}})
    send_resp conn, :ok, "OK"
  end

  def delete(conn, _params) do
    Rgb.LedThing.send(:unset)
    send_resp conn, :ok, "OK"
  end

  def fade(conn, _params) do
    Rgb.LedThing.send(:fade)
    send_resp conn, :ok, "OK"
  end
end
