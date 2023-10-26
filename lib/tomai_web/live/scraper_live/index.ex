defmodule TomaiWeb.ScraperLive.Index do
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Scraper</h1>
    </div>
    """
  end
end
