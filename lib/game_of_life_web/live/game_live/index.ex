defmodule GameOfLifeWeb.GameLive.Index do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Game

  @initial_board_size 20

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:speed, 500)
     |> assign(:sleep, 500)
     |> assign(:board_size, @initial_board_size)
     |> assign(:game, Game.new(@initial_board_size))
     |> assign(:playing, false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Game")
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

  def handle_event("change_board", %{"value" => size}, socket) do
    {size, ""} = Integer.parse(size)

    updated =
      socket
      |> assign(board_size: size)
      |> assign(:game, %{Game.resize(socket.assigns.game, size) | id: :rand.uniform(100)})

    {:noreply, push_patch(updated, to: "/game")}
  end

  def handle_event("speed", %{"value" => speed}, socket) do
    speed =
      speed
      |> Integer.parse()
      |> elem(0)

    {:noreply,
     socket
     |> assign(:sleep, max(1000 - speed, 200))
     |> assign(:speed, speed)}
  end

  @impl true
  def handle_info(:play, socket) do
    # Se todas as celulas estiverem mortas, stop.
    game = socket.assigns.game

    if not socket.assigns.playing or Game.all_dead?(game) do
      {:noreply, socket}
    else
      Process.send_after(self(), :play, socket.assigns.sleep)
      {:noreply, assign(socket, :game, Game.play(game))}
    end
  end

  defp flip_state(game, x, y, "live"), do: Game.dead(game, {x, y})
  defp flip_state(game, x, y, "dead"), do: Game.live(game, {x, y})
end
