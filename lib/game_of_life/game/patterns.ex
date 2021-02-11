defmodule GameOfLife.Game.Patterns do
  @moduledoc false

  @spec get_patterns :: %{String.t() => list({integer(), integer()})}
  def get_patterns() do
    %{
      "Gosper Glider Gun" => gosper_glider_gun(),
      "Blinker" => blinker(),
      "Beacon" => beacon(),
      "Combination" => combination(),
      "Glider" => glider()
    }
  end

  defp gosper_glider_gun do
    [
      {5, 1},
      {5, 2},
      {6, 1},
      {6, 2},
      {5, 11},
      {6, 11},
      {7, 11},
      {4, 12},
      {3, 13},
      {3, 14},
      {8, 12},
      {9, 13},
      {9, 14},
      {6, 15},
      {4, 16},
      {5, 17},
      {6, 17},
      {7, 17},
      {6, 18},
      {8, 16},
      {3, 21},
      {4, 21},
      {5, 21},
      {3, 22},
      {4, 22},
      {5, 22},
      {2, 23},
      {6, 23},
      {1, 25},
      {2, 25},
      {6, 25},
      {7, 25},
      {3, 35},
      {4, 35},
      {3, 36},
      {4, 36}
    ]
  end

  defp blinker, do: [{0, 1}, {1, 1}, {2, 1}]

  defp beacon, do: [{1, 1}, {2, 1}, {1, 2}, {4, 3}, {3, 4}, {4, 4}]

  defp glider, do: [{1, 0}, {2, 1}, {0, 2}, {1, 2}, {2, 2}]

  defp combination, do: [{0, 12}, {1, 12}, {2, 12}, {1, 6}, {2, 7}, {0, 8}, {1, 8}, {2, 8}]
end
