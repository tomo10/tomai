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
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    # CSS class selector for headlines on afr.com/companies/financial-services
    items =
      Floki.find(document, "_2slqK")
      |> Enum.map(fn story ->
        %{
          title: Floki.find(story, "h3") |> Floki.text(),
          summary: Floki.find(story, "p") |> Floki.text()
        }
      end)

    next_requests = []

    %{items: items, requests: next_requests}
  end
end
