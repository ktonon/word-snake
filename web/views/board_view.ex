defmodule WordSnake.BoardView do
  use WordSnake.Web, :view

  def render(_, %{board: board}) do
    board
  end
end
