defmodule GameOfLife.GameTest do
  use ExUnit.Case, async: true

  alias GameOfLife.Game

  doctest Game

  test "ensure subsequent stages of the glider pattern works" do
    board =
      Enum.reduce(
        [{2, 0}, {3, 1}, {1, 2}, {2, 2}, {3, 2}],
        Game.new(5),
        &Game.live(&2, &1)
      )

    step_0_expected = %{
      0 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead},
      1 => %{0 => :dead, 1 => :dead, 2 => :live, 3 => :dead, 4 => :dead},
      2 => %{0 => :live, 1 => :dead, 2 => :live, 3 => :dead, 4 => :dead},
      3 => %{0 => :dead, 1 => :live, 2 => :live, 3 => :dead, 4 => :dead},
      4 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead}
    }

    assert board.cells == step_0_expected

    step_1_expected = %{
      0 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead},
      1 => %{0 => :dead, 1 => :live, 2 => :dead, 3 => :dead, 4 => :dead},
      2 => %{0 => :dead, 1 => :dead, 2 => :live, 3 => :live, 4 => :dead},
      3 => %{0 => :dead, 1 => :live, 2 => :live, 3 => :dead, 4 => :dead},
      4 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead}
    }

    board = Game.play(board)
    assert board.cells == step_1_expected

    step_2_expected = %{
      0 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead},
      1 => %{0 => :dead, 1 => :dead, 2 => :live, 3 => :dead, 4 => :dead},
      2 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :live, 4 => :dead},
      3 => %{0 => :dead, 1 => :live, 2 => :live, 3 => :live, 4 => :dead},
      4 => %{0 => :dead, 1 => :dead, 2 => :dead, 3 => :dead, 4 => :dead}
    }

    board = Game.play(board)
    assert board.cells == step_2_expected
  end

  test "any living cell with less than two living neighbors dies of loneliness" do
    game =
      3
      |> Game.new()
      |> Game.live({2, 2})

    assert Game.play(game).cells == %{
             0 => %{0 => :dead, 1 => :dead, 2 => :dead},
             1 => %{0 => :dead, 1 => :dead, 2 => :dead},
             2 => %{0 => :dead, 1 => :dead, 2 => :dead}
           }
  end

  test "any living cell with more than three living neighbors dies of overpopulation" do
    game =
      Game.new(3)
      |> Game.live({0, 0})
      |> Game.live({0, 1})
      |> Game.live({0, 2})
      |> Game.live({1, 0})
      |> Game.live({1, 2})

    assert Game.play(game).cells == %{
             0 => %{0 => :live, 1 => :dead, 2 => :live},
             1 => %{0 => :live, 1 => :dead, 2 => :live},
             2 => %{0 => :dead, 1 => :dead, 2 => :dead}
           }
  end

  test "any dead cell with exactly three living neighbors becomes a living cell" do
    game =
      Game.new(3)
      |> Game.live({0, 0})
      |> Game.live({1, 0})
      |> Game.live({2, 0})

    assert Game.play(game).cells == %{
             0 => %{0 => :dead, 1 => :dead, 2 => :dead},
             1 => %{0 => :live, 1 => :live, 2 => :dead},
             2 => %{0 => :dead, 1 => :dead, 2 => :dead}
           }
  end

  test "any living cell with two or three living neighbors remains in the same state for the next generation" do
    game =
      Game.new(3)
      |> Game.live({0, 0})
      |> Game.live({1, 0})
      |> Game.live({1, 1})

    assert Game.play(game).cells == %{
             0 => %{0 => :live, 1 => :live, 2 => :dead},
             1 => %{0 => :live, 1 => :live, 2 => :dead},
             2 => %{0 => :dead, 1 => :dead, 2 => :dead}
           }
  end
end
