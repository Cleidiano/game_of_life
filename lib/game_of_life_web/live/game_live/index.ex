defmodule GameOfLifeWeb.GameLive.Index do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Game

  @initial_board_size 40
  @max_board_size 80

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:speed, 500)
     |> assign(:sleep, 1500)
     |> assign(:generation, 0)
     |> assign(:game_state, :paused)
     |> assign(:board_size, @initial_board_size)
     |> create_game("Gosper Glider Gun")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Game")
  end

  @impl true
  def handle_event("flip_state", %{"x" => x, "y" => y}, socket) do
    {x_axis, ""} = Integer.parse(x)
    {y_axis, ""} = Integer.parse(y)

    {:noreply, assign(socket, :game, Game.flip_state(socket.assigns.game, {x_axis, y_axis}))}
  end

  @impl true
  def handle_event("play", _, socket), do: start_game(socket)
  def handle_event("pause", _, socket), do: pause(socket)
  def handle_event("stop", _, socket), do: stop(socket)

  def handle_event("load_pattern", %{"pattern" => %{"name" => pattern}}, socket) do
    {:noreply, create_game(socket, pattern)}
  end

  def handle_event("speed", %{"value" => speed}, socket) do
    speed =
      speed
      |> Integer.parse()
      |> elem(0)

    {:noreply,
     socket
     |> assign(:sleep, max(2000 - speed, 50))
     |> assign(:speed, speed)}
  end

  @impl true
  def handle_info(:play, socket), do: play(socket)

  defp start_game(socket) do
    socket
    |> assign(:game_state, :playing)
    |> play()
  end

  defp play(socket) do
    game = socket.assigns.game

    case socket.assigns.game_state do
      :paused ->
        pause(socket)

      :stopped ->
        stop(socket)

      :playing ->
        if Game.all_dead?(game) do
          pause(socket)
        else
          Process.send_after(self(), :play, socket.assigns.sleep)

          {:noreply,
           socket
           |> assign(:game, Game.play(game, @max_board_size))
           |> increment_generation()}
        end
    end
  end

  defp pause(socket) do
    {:noreply, assign(socket, :game_state, :paused)}
  end

  defp stop(socket) do
    {:noreply,
     socket
     |> create_game(socket.assigns.loaded_pattern)
     |> assign(:game_state, :stopped)
     |> assign(:generation, 0)}
  end

  defp increment_generation(socket) do
    assign(socket, :generation, socket.assigns.generation + 1)
  end

  defp create_game(socket, name) do
    pattern = Map.fetch!(game_patterns(), name)

    new_game =
      @initial_board_size
      |> Game.new()
      |> Game.live(pattern)

    socket
    |> assign(:game, new_game)
    |> assign(:loaded_pattern, name)
  end

  defp game_patterns do
    Game.Patterns.get_patterns()
  end
end
