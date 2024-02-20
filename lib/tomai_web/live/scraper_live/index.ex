defmodule TomaiWeb.ScraperLive.Index do
  alias TomaiWeb.GeneralComponents
  alias Tomai.News.AfrStream
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    AfrStream.connect(self())

    {:ok, assign(socket, :articles, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="grid grid-cols-2 gap-12">
        <div class="col-span-1 pb-2">
          <button
            phx-click="scrape"
            class="bg-yellow-500 hover:bg-yellow-600 text-white font-semibold py-2 px-4 rounded focus:outline-none focus:ring focus:ring-yellow-300"
          >
            Australian Financial Review Scraper
          </button>
          <button
            phx-click="get-state"
            class="bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded focus:outline-none focus:ring focus:ring-blue-300"
          >
            Fetch state
          </button>
          <ul>
            <%= for description <- descriptions() do %>
              <GeneralComponents.text_section description={description} />
            <% end %>
          </ul>
        </div>
        <div class="col-span-1 pb-2">
          <ul class="divide-y">
            <li :for={article <- @articles}>
              <a href="www.bbc.co.uk" target="_window">
                <div class="px-4 py-4">
                  <%= if article.sentiment do %>
                    <div class={[class_for_sentiment(article.sentiment), "p-1 rounded-lg"]}>
                      <p class="text-sm">Sentiment: <%= article.sentiment %></p>
                    </div>
                  <% end %>
                  <h2 class="text-md font-medium"><%= article.title %></h2>
                  <p class="text-sm"><%= article.summary %></p>
                  <div class="inline-flex space-x-2"></div>
                </div>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  defp class_for_sentiment("positive"), do: "bg-green-100"
  defp class_for_sentiment("negative"), do: "bg-red-100"
  defp class_for_sentiment(_class), do: "bg-gray-100"

  @impl true
  def handle_event("scrape", _params, socket) do
    Afr.start_afr_spider()

    {:noreply, socket}
  end

  @impl true
  def handle_event("get-state", _unsigned_params, socket) do
    raw_articles = AfrStream.get_state() |> Map.get(:items)

    socket = run_enrichment_task(socket, raw_articles)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:afr_stream, new_articles}, socket) do
    socket = run_enrichment_task(socket, new_articles)

    {:noreply, socket}
  end

  def handle_info({_task, enriched_articles}, socket) do
    socket =
      socket
      |> update(:articles, fn articles -> enriched_articles ++ articles end)

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket) do
    {:noreply, socket}
  end

  defp do_sentiment_enrich(articles) do
    Task.async(fn ->
      # this split ensures only articles without sentimet anylsis are enriched
      {_ignore, enrich} = Enum.split_with(articles, &(&1.sentiment != nil))
      Tomai.News.Enrichments.Sentiment.predict(enrich)
    end)
  end

  defp run_enrichment_task(socket, articles) do
    enrich_task = do_sentiment_enrich(articles)
    assign(socket, :enrich_task, enrich_task)
  end

  defp descriptions do
    [
      "We are scraping data from the Australian Financial Review using the Crawly library. Once articles are scraper they are sent to the GenServer and from there to the LiveView.",
      "Once rendered, the articles are enriched with Sentiment Analysis. This project demonstrates the power of Elixir's AI libraries and capablities."
    ]
  end
end
