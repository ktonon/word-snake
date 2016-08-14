defmodule WordSnake.Router do
  use WordSnake.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WordSnake do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", WordSnake do
    pipe_through :api
  end
end
