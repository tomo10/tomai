defmodule TomaiWeb.FeedLive.Index do
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    articles = Tomai.News.Stream.connect(self())

    socket =
      socket
      |> process_enrichments(articles)
      |> assign(:articles, articles)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto my-8">
      <h1 class="text-xl">News Feed</h1>
      <ul class="divide-y divide-gray-100">
        <li :for={article <- @articles}>
          <a href={article.url} target="_window">
            <div class={[class_for_sentiment(article.sentiment), "px-4 py-4"]}>
              <h2 class="text-md font-medium"><%= article.title %></h2>
              <p class="text-sm">Sentiment:<%= article.sentiment %></p>
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
    """
  end

  defp class_for_sentiment("positive"), do: "bg-green-100"
  defp class_for_sentiment("negative"), do: "bg-red-100"
  defp class_for_sentiment(_class), do: ""

  @impl true
  def handle_info({:stream, new_articles}, socket) do
    socket =
      socket
      |> process_enrichments(new_articles)
      |> update(:articles, fn articles -> new_articles ++ articles end)

    {:noreply, socket}
  end

  # current issues:
  # 1. New articles are not being added to the list. They are replacing the whole list

  def handle_info({_task, articles}, socket) do
    socket =
      socket
      |> assign(:articles, articles)

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
      {ignore, enrich} = Enum.split_with(articles, &(&1.entities != nil))
      ignore ++ Tomai.News.Enrichments.NER.predict(enrich)
    end)
  end

  defp do_sentiment_enrich(articles) do
    Task.async(fn ->
      {ignore, enrich} = Enum.split_with(articles, &(&1.sentiment != nil))
      ignore ++ Tomai.News.Enrichments.Sentiment.predict(enrich)
    end)
  end

  defp process_enrichments(socket, articles) do
    socket
    |> do_all_enrichments(articles)
  end
end
