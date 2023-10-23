defmodule Tomai.News.API do
  @moduledoc """
  A simple wrapper around the NewsAPI REST API.
  """
  alias Tomai.News.Article

  @doc """
  Returns the top headlines in the country.
  """
  def top_headlines() do
    "top-headlines"
    |> url()
    |> Req.get(params: %{country: "us", apiKey: api_key()})
    |> handle_response()
  end

  defp url(path) do
    base_url() <> path
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    body["articles"]
    |> Enum.reject(&(&1["content"] == nil))
    |> Enum.map(&normalize_article/1)
  end

  defp normalize_article(body) do
    %Article{
      author: body["author"],
      content: body["content"],
      description: body["description"],
      published_at: body["published_at"],
      source: get_in(body, ["source", "id"]),
      title: body["title"],
      url: body["url"],
      url_to_image: body["urlToImage"]
    }
  end

  defp base_url, do: "https://newsapi.org/v2/"

  defp api_key, do: Application.get_env(:tomai, __MODULE__)[:api_key]
end
