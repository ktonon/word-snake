defmodule WordSnake.BoardController do
  use WordSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    String.to_integer(id)
    |> :random.seed

    rows = 0..3
    cols = 0..3

    cells =
    Enum.map(rows, fn y ->
      Enum.map(cols, fn x ->
        %{ "x" => x,
           "y" => y,
           "letter" => <<:random.uniform(26) + 64>>
         }
      end)
    end)
    |> List.flatten

    render conn, board: %{
      cells: cells
    }
  end
end
