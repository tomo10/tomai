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
    """
  end

  defp class_for_sentiment("positive"), do: "bg-green-100"
  defp class_for_sentiment("negative"), do: "bg-red-100"
  defp class_for_sentiment(_class), do: "bg-gray-100"

  @impl true
  def handle_event("scrape", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:afr_stream, new_articles}, socket) do
    socket = run_enrichment_task(socket, new_articles)

    {:noreply, assign(socket, :articles, new_articles)}
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
      {_ignore, enrich} = Enum.split_with(articles, &(&1.sentiment != nil))
      Tomai.News.Enrichments.Sentiment.predict(enrich)
    end)
  end

  defp run_enrichment_task(socket, articles) do
    enrich_task = do_sentiment_enrich(articles)
    assign(socket, :enrich_task, enrich_task)
  end
end
