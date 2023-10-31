defmodule TomaiWeb.ScraperLive.Index do
  use TomaiWeb, :live_view
  alias Tomai.News.AfrStream

  @impl true
  def mount(_params, _session, socket) do
    AfrStream.connect(self())

    {:ok, assign(socket, :articles, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        phx-click="scrape"
        class="cursor-pointer bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded"
      >
        Scrape AFR
      </div>
      <ul class="divide-y">
        <li :for={article <- @articles}>
          <a href="www.bbc.co.uk" target="_window">
            <div class="px-4 py-4">
              <h2 class="text-md font-medium"><%= article.title %></h2>
              <p class="text-sm"><%= article.summary %></p>
              <div class="inline-flex space-x-2"></div>
            </div>
          </a>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("scrape", _params, socket) do
    Afr.start_afr_spider()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:afr_stream, new_articles}, socket) do
    {:noreply, assign(socket, :articles, new_articles)}
  end
end
