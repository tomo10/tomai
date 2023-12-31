defmodule Afr do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.afr.com/companies/financial-services"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://www.afr.com/companies/financial-services"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # CSS class selector for headlines on afr.com/companies/financial-services
    article_css_class = "._2slqK"

    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    items =
      Floki.find(document, article_css_class)
      |> Enum.map(fn story ->
        %{
          title: Floki.find(story, "h3") |> Floki.text(),
          summary: Floki.find(story, "p") |> Floki.text(),
          sentiment: nil
        }
      end)

    GenServer.cast(Tomai.News.AfrStream, {:scraped_data, items})

    %{items: items, requests: []}
  end

  def start_afr_spider() do
    Crawly.Engine.start_spider(Afr)
  end
end
