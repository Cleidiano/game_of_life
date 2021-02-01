defmodule GameOfLifeWeb.GameLive.Index do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Game

  @initial_board_size 40

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
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
  def handle_event("play", _, socket), do: start_game(socket)
  def handle_event("pause", _, socket), do: pause(socket)
  def handle_event("stop", _, socket), do: stop(socket)

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
    play(socket)
  end

  defp start_game(socket) do
    socket
    |> assign(:playing, true)
    |> play()
  end

  defp play(socket) do
    game = socket.assigns.game

    if not socket.assigns.playing or Game.all_dead?(game) do
      pause(socket)
    else
      Process.send_after(self(), :play, socket.assigns.sleep)
      {:noreply, assign(socket, :game, Game.play(game, 100))}
    end
  end

  defp pause(socket) do
    {:noreply, assign(socket, playing: false)}
  end

  defp stop(socket) do
    {:noreply,
     socket
     |> assign(playing: false)
     |> assign(:game, Game.new(socket.assigns.board_size))}
  end

  defp flip_state(game, x, y, "live"), do: Game.dead(game, {x, y})
  defp flip_state(game, x, y, "dead"), do: Game.live(game, {x, y})

  defp bind_event_when(state, event) do
    if state, do: event
  end
end
