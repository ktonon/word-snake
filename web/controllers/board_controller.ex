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
        %{ "letter" => <<:random.uniform(26) + 64>>,
           "id" => cell_id(x, y),
           "x" => x,
           "y" => y,
           "adj" => neighbours(x, y, cols, rows)
         }
      end)
    end)
    |> List.flatten

    render conn, board: %{
      cells: cells
    }
  end

  defp cell_id(x, y) do
    "#{x}_#{y}"
  end

  defp neighbours(x, y, cols, rows) do
    neighbour = fn (a, b) ->
      (a in cols) && (b in rows) && cell_id(a, b)
    end
    [
      neighbour.(x - 1, y - 1),
      neighbour.(x - 1, y),
      neighbour.(x - 1, y + 1),
      neighbour.(x, y - 1),
      neighbour.(x, y + 1),
      neighbour.(x + 1, y - 1),
      neighbour.(x + 1, y),
      neighbour.(x + 1, y + 1),
    ] |> Enum.filter(&(&1))
  end
end
