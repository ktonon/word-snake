defmodule WordSnake.BoardControllerTest do
  use WordSnake.ConnCase

  test "/show/:id returns a board with cells", %{conn: conn} do
    r = get(conn, board_path(conn, :show, "123"))
    assert r.status == 200
    assert %{"cells" => cells } = Poison.decode!(r.resp_body)
    assert !Enum.empty?(cells)
  end
end
