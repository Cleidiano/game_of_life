defmodule GameOfLifeWeb.GameLive.Index do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game, game())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Game")
    |> assign(:game, game())
  end

  @impl true
  def handle_event("flip_state", %{"cell_value" => state, "x_axis" => x, "y_axis" => y}, socket) do
    {x_axis, ""} = Integer.parse(x)
    {y_axis, ""} = Integer.parse(y)

    game = flip_state(socket.assigns.game, x_axis, y_axis, state)

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event("play", _, socket) do
    Process.send(self(), :play, [])
    {:noreply, assign(socket, :playing, true)}
  end

  def handle_event("stop", _, socket) do
    {:noreply, assign(socket, :playing, false)}
  end

  @impl true
  def handle_info(:play, socket) do
    # Se todas as celulas estiverem mortas, stop.
    game = socket.assigns.game

    if not socket.assigns.playing or Game.all_dead?(game) do
      {:noreply, socket}
    else
      Process.send_after(self(), :play, 500)
      {:noreply, assign(socket, :game, Game.play(game))}
    end
  end

  defp game do
    Game.new(10)
  end

  defp flip_state(game, x, y, "live"), do: Game.dead(game, {x, y})
  defp flip_state(game, x, y, "dead"), do: Game.live(game, {x, y})
end
