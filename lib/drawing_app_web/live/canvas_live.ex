defmodule DrawingAppWeb.CanvasLive do
  use DrawingAppWeb, :live_view
  alias DrawingApp.Drawings

  def mount(_params, session, socket) do
    if connected?(socket) do
      {:ok, drawing} = Drawings.get_or_create_drawing()
      Phoenix.PubSub.subscribe(DrawingApp.PubSub, "canvas")
      user_id = Map.get(session, "user_id")

      socket = socket
      |> assign(drawing: drawing, users: %{}, user_id: user_id)
      |> push_event("init_canvas", %{data: drawing.data["data"]})

      {:ok, socket}
    else
      {:ok, assign(socket, drawing: nil, users: %{}, user_id: nil)}
    end
  end

  def handle_event("draw", %{"data" => data}, socket) do
    {:ok, updated_drawing} = Drawings.update_drawing(socket.assigns.drawing, %{data: data})
    Phoenix.PubSub.broadcast(DrawingApp.PubSub, "canvas", {:update_canvas, data})
    {:noreply, assign(socket, drawing: updated_drawing)}
  end

  def handle_event("get_initial_state", _, socket) do
    {:reply, %{data: socket.assigns.drawing.data["data"]}, socket}
  end

  def handle_event("cursor_moved", %{"x" => x, "y" => y}, socket) do
    user_id = socket.assigns.user_id
    Phoenix.PubSub.broadcast(DrawingApp.PubSub, "canvas", {:cursor_moved, user_id, x, y})
    {:noreply, socket}
  end

  def handle_event("cursor_left", _params, socket) do
    user_id = socket.assigns.user_id
    Phoenix.PubSub.broadcast(DrawingApp.PubSub, "canvas", {:cursor_left, user_id})
    {:noreply, socket}
  end

  def handle_info({:update_canvas, data}, socket) do
    {:noreply, push_event(socket, "update_canvas", %{data: data})}
  end

  def handle_info({:cursor_moved, user_id, x, y}, socket) do
    updated_users = Map.put(socket.assigns.users, user_id, %{x: x, y: y})
    socket = assign(socket, users: updated_users)
    {:noreply, push_event(socket, "cursor_moved", %{user: user_id, x: x, y: y})}
  end

  def handle_info({:cursor_left, user_id}, socket) do
    updated_users = Map.delete(socket.assigns.users, user_id)
    socket = assign(socket, users: updated_users)
    {:noreply, push_event(socket, "cursor_left", %{user: user_id})}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-4">Collaborative Drawing Canvas</h1>
      <div class="relative">
        <canvas id="drawing-canvas" phx-hook="Canvas" class="border border-gray-300"
                width="800" height="600" phx-update="ignore">
        </canvas>
      </div>
    </div>
    """
  end
end
