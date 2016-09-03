defmodule WordSnake.BoardController do
  use WordSnake.Web, :controller
  import WordSnake.RandomLetter

  def show(conn, %{"id" => id}) do
    id
    |> String.to_integer
    |> :random.seed

    rows = 0..3
    cols = 0..3

    cells =
    Enum.map(rows, fn y ->
      Enum.map(cols, fn x -> %{
        "letter" => random_letter,
        "id" => cell_id(x, y),
        "x" => x,
        "y" => y,
        "adj" => neighbours(x, y, cols, rows),
      }
      end)
    end)
    render conn, board: %{
      cells: List.flatten(cells)
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
