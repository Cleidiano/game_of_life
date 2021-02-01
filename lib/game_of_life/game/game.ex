defmodule GameOfLife.Game do
  defstruct id: nil, cells: %{}

  @type t :: %__MODULE__{
          cells: map()
        }

  @type point :: {x :: pos_integer(), y :: pos_integer()}
  @type cell :: point
  @type board_size_limit :: integer()

  @doc """
    Create a cartesian plane with the specified size

      The initial cell state is dead that is represented by boolean `false`.

      ### Exemple

      iex> GameOfLife.Game.new(2, "id")
      %GameOfLife.Game{
        id: "id",
        cells: %{
          0 => %{0 => :dead, 1 => :dead},
          1 => %{0 => :dead, 1 => :dead}
        }
      }
  """
  @spec new(pos_integer) :: t()
  def new(size, id \\ :rand.uniform(100)) when size > 0 do
    %__MODULE__{
      cells: create_grid_of(size),
      id: id
    }
  end

  defp create_grid_of(size) do
    range = Range.new(0, size - 1)
    row = create_row(range)

    range
    |> Enum.map(&{&1, row})
    |> Map.new()
  end

  defp create_row(range) do
    range
    |> Enum.map(&{&1, :dead})
    |> Map.new()
  end

  @doc """
    Play and generate the next generation of cells
  """
  @spec play(t, board_size_limit) :: t()
  def play(game, board_size_limit) do
    played_game =
      game
      |> get_all_cells_allowing_extra_boundary(board_size_limit)
      |> Enum.map(fn cell -> {cell, next_cell_state(game, cell)} end)
      |> Enum.reduce(game, fn {cell, state}, acc -> apply_state(acc, cell, state) end)

    max =
      played_game.cells
      |> Enum.max_by(&map_size(elem(&1, 1)))
      |> elem(1)
      |> map_size()

    if Enum.any?(played_game.cells, fn {_index, row} -> map_size(row) < max end) do
      %{played_game | cells: resize_cells_of(played_game, max)}
    else
      played_game
    end
  end

  defp get_all_cells_allowing_extra_boundary(game, board_size_limit) do
    last_row = fn x -> Map.get(game.cells, x - 1, %{}) end

    for x <- 0..map_size(game.cells),
        y <- 0..map_size(Map.get_lazy(game.cells, x, fn -> last_row.(x) end)),
        x <= board_size_limit,
        y <= board_size_limit do
      {x, y}
    end
  end

  defp resize_cells_of(game, size) do
    resized_cells =
      Enum.map(
        game.cells,
        fn
          {index, row} when map_size(row) < size ->
            range = Range.new(0, size - 1)

            updated_row =
              range
              |> create_row()
              |> Map.merge(row)

            {index, updated_row}

          current ->
            current
        end
      )

    Map.new(resized_cells)
  end

  @doc """
    Make a cell live

    ### Exemple
      iex> alias GameOfLife.Game
      ...> g = Game.new(3, "id")
      ...> g = Game.live(g, {0, 0})
      ...> Game.live(g, {1, 2})
      %GameOfLife.Game{
        id: "id",
        cells: %{
             0 => %{0 => :live, 1 => :dead, 2 => :dead},
             1 => %{0 => :dead, 1 => :dead, 2 => :live},
             2 => %{0 => :dead, 1 => :dead, 2 => :dead}
        }
      }
  """
  @spec live(t(), cell()) :: t()
  def live(grid, cell) do
    apply_state(grid, cell, :live)
  end

  @doc """
    Make a cell dead

    ### Exemple
      iex> alias GameOfLife.Game
      ...> g = Game.new(3, "id")
      ...> g = Game.live(g, {0, 0})
      ...> Game.dead(g, {0, 0})
      %GameOfLife.Game{
        id: "id",
        cells: %{
              0 => %{0 => :dead, 1 => :dead, 2 => :dead},
              1 => %{0 => :dead, 1 => :dead, 2 => :dead},
              2 => %{0 => :dead, 1 => :dead, 2 => :dead}
        }
      }
  """
  @spec dead(t(), cell()) :: t()
  def dead(grid, cell) do
    apply_state(grid, cell, :dead)
  end

  @doc """
    Verify if all cells are dead

    ### Exemple
      iex> alias GameOfLife.Game
      ...> game = Game.new(3)
      ...> Game.all_dead?(game)
      true

      iex> alias GameOfLife.Game
      ...> game = Game.new(3)
      ...> game = Game.live(game, {2, 0})
      ...> Game.all_dead?(game)
      false
  """
  @spec all_dead?(t()) :: boolean
  def all_dead?(grid) do
    any_live? =
      Enum.any?(
        grid.cells,
        fn {_, row} ->
          row
          |> Map.values()
          |> Enum.member?(:live)
        end
      )

    not any_live?
  end

  defp next_cell_state(grid, cell) do
    live_neighbors =
      grid
      |> neighbors(cell)
      |> Enum.count(&live?(grid, &1))

    cond do
      live_neighbors < 2 -> :dead
      live_neighbors > 3 -> :dead
      live_neighbors == 3 -> :live
      live_neighbors in [2, 3] -> get_cell_state(grid, cell)
    end
  end

  defp neighbors(_grid, {x, y}) do
    for x1 <- (x - 1)..(x + 1),
        y1 <- (y - 1)..(y + 1),
        x1 >= 0,
        y1 >= 0,
        x1 != x or y1 != y do
      {x1, y1}
    end
  end

  defp live?(grid, cell) do
    get_cell_state(grid, cell) == :live
  end

  defp get_cell_state(grid, {x, y}) do
    grid.cells
    |> Map.get(x, %{})
    |> Map.get(y, :dead)
  end

  defp apply_state(grid, {x, y} = cell, state) do
    current_state = get_cell_state(grid, cell)

    if current_state != state do
      %{grid | cells: put_in(grid.cells, [Access.key(x, %{}), y], state)}
    else
      grid
    end
  end
end
