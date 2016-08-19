defmodule WordSnake.BoardController do
  use WordSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    render conn, board: %{
      cells: String.split(id, "")
    }
  end
end
