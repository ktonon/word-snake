defmodule WordSnake.BoardController do
  use WordSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    String.to_integer(id)
    |> :random.seed

    letters = 1..20
    |> Enum.map(fn _ ->
      <<:random.uniform(26) + 65>>
    end)

    render conn, board: %{
      cells: letters
    }
  end
end
