defmodule GameOfLife.Game do
  defstruct cells: %{}

  @type t :: %__MODULE__{
          cells: map()
        }

  @type point :: {x :: pos_integer(), y :: pos_integer()}
  @type cell :: point

  @doc """
    Create a cartesian plane with the specified size

      The initial cell state is dead that is represented by boolean `false`.

      ### Exemple

      iex> GameOfLife.Game.new(2)
      %GameOfLife.Game{
        cells: %{
          0 => %{0 => :dead, 1 => :dead},
          1 => %{0 => :dead, 1 => :dead}
        }
      }
  """
  @spec new(pos_integer) :: t()
  def new(size) when size > 0 do
    %__MODULE__{
      cells: create_grid_of(size)
    }
  end

  defp create_grid_of(size) do
    range = Range.new(0, size - 1)

    row =
      range
      |> Enum.map(&{&1, :dead})
      |> Map.new()

    range
    |> Enum.map(&{&1, row})
    |> Map.new()
  end

  @doc """
    Play and generate the next generation of cells
  """
  @spec play(t()) :: t()
  def play(grid) do
    limit = map_size(grid.cells) - 1

    exhaustive_cells =
      for x <- 0..limit, y <- 0..limit do
        {x, y}
      end

    exhaustive_cells
    |> Enum.map(fn cell -> {cell, next_cell_state(grid, cell)} end)
    |> Enum.reduce(grid, fn {cell, state}, acc -> apply_state(acc, cell, state) end)
  end

  @doc """
    Make a cell live

    ### Exemple
      iex> alias GameOfLife.Game
      ...> g = Game.new(3)
      ...> g = Game.live(g, {0, 0})
      ...> Game.live(g, {1, 2})
      %GameOfLife.Game{
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
      ...> g = Game.new(3)
      ...> g = Game.live(g, {0, 0})
      ...> Game.dead(g, {0, 0})
      %GameOfLife.Game{
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

  defp neighbors(grid, {x, y}) do
    boundary = 0..(map_size(grid.cells) - 1)

    for x1 <- (x - 1)..(x + 1),
        y1 <- (y - 1)..(y + 1),
        x1 in boundary,
        y1 in boundary,
        x1 != x or y1 != y do
      {x1, y1}
    end
  end

  defp live?(grid, cell) do
    get_cell_state(grid, cell) == :live
  end

  defp get_cell_state(grid, {x, y}) do
    grid.cells
    |> Map.fetch!(x)
    |> Map.fetch!(y)
  end

  defp apply_state(grid, {x, y} = cell, state) do
    current_state = get_cell_state(grid, cell)

    if current_state != state do
      put_in(grid.cells[x][y], state)
    else
      grid
    end
  end
end
