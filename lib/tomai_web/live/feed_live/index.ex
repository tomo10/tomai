defmodule TomaiWeb.FeedLive.Index do
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    articles = Tomai.News.Stream.connect(self())

    socket =
      socket
      |> assign(:articles, [])
      |> process_enrichments(articles)

    {:ok, socket}
  end

  def text_section(assigns) do
    ~H"""
    <div class="p-2">
      <h2 class="text-md font-medium"><%= @description %></h2>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="grid grid-cols-2 gap-12">
        <div class="col-span-1 pb-2">
          <h1 class="text-xl">About</h1>
          <ul>
            <%= for description <- descriptions() do %>
              <.text_section description={description} />
            <% end %>
          </ul>
        </div>
        <div class="col-span-1">
          <h1 class="text-xl">News Feed</h1>
          <ul class="divide-y">
            <li :for={article <- @articles}>
              <a href={article.url} target="_window">
                <div class="px-4 py-4">
                  <h2 class="text-md font-medium"><%= article.title %></h2>
                  <div class={[class_for_sentiment(article.sentiment), "p-1 rounded-lg"]}>
                    <p class="text-sm">Sentiment: <%= article.sentiment %></p>
                  </div>
                  <p class="text-sm"><%= article.description %></p>
                  <div class="inline-flex space-x-2">
                    <%= if article.entities do %>
                      <span
                        :for={entity <- article.entities}
                        class="p-[0.5] bg-gray-50 rounded-md text-xs"
                      >
                        <%= entity.phrase %>-<%= entity.label %>
                      </span>
                    <% end %>
                  </div>
                </div>
              </a>
            </li>
          </ul>
        </div>
        <div class="col-span-1" />
      </div>
    </div>
    """
  end

  defp class_for_sentiment("positive"), do: "bg-green-100"
  defp class_for_sentiment("negative"), do: "bg-red-100"
  defp class_for_sentiment(_class), do: "bg-gray-100"

  @impl true
  def handle_info({:stream, new_articles}, socket) do
    socket =
      socket
      |> process_enrichments(new_articles)

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

  defp do_all_enrichments(socket, articles) do
    enrich_tasks =
      do_ner_enrich(articles)
      |> Task.await()
      |> do_sentiment_enrich()

    assign(socket, :enrich_tasks, enrich_tasks)
  end

  defp do_ner_enrich(articles) do
    Task.async(fn ->
      {_ignore, enrich} = Enum.split_with(articles, &(&1.entities != nil))
      Tomai.News.Enrichments.NER.predict(enrich)
    end)
  end

  defp do_sentiment_enrich(articles) do
    Task.async(fn ->
      {_ignore, enrich} = Enum.split_with(articles, &(&1.sentiment != nil))
      Tomai.News.Enrichments.Sentiment.predict(enrich)
    end)
  end

  defp process_enrichments(socket, articles) do
    socket
    |> do_all_enrichments(articles)
  end

  defp descriptions do
    [
      "We are pulling data from the newsapi.org using GenServer behaviour. We then run a sentiment analysis and Named Entity Recognition (NER) on the title of the article.",
      "New articles are polled every 1-2 minutes to simlulate a real time feed. This project demonstrates the power of Elixir's AI libraries and capablities."
    ]
  end
end
