defmodule RgbWeb.PageController do
  use RgbWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
