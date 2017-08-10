defmodule RgbWeb.Router do
  use RgbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", RgbWeb do
  #   pipe_through :browser # Use the default browser stack

  #   get "/", PageController, :index
  # end

  scope "/", RgbWeb do
    pipe_through :api

    get "/", ApiController, :index
    post "/", ApiController, :post
    delete "/", ApiController, :delete
    post "/fade", ApiController, :fade
  end

  # Other scopes may use custom stacks.
  # scope "/api", RgbWeb do
  #   pipe_through :api
  # end
end
