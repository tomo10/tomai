defmodule TomaiWeb.MiloLive.Index do
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :messages, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto my-8">
      <h1 class="text-3xl font-semibold mb-4">Milo</h1>
      <div class="mb-4">
        <form phx-submit="send-message">
          <input
            phx-debounce="300"
            phx-value-message="message-input"
            class="border rounded p-2 w-full"
            placeholder="Type your message..."
          />
          <button type="submit" class="bg-blue-500 text-white p-2 rounded mt-2">Submit</button>
        </form>
      </div>
      <div>
        <div :for={message <- @messages} class="bg-gray-100 p-2 mb-2 rounded">
          <%= message.content %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send-message", %{"message-input" => message}, socket) do
    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end
end
