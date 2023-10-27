defmodule TomaiWeb.ScraperLive.Index do
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div
        phx-click="scrape"
        class="cursor-pointer bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded"
      >
        Scrape AFR
      </div>
    </div>
    """
  end

  def handle_event("scrape", _params, socket) do
    # want to start the Crawly.Spider here

    {:noreply, socket}
  end
end
