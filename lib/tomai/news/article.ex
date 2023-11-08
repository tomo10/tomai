defmodule Tomai.News.Article do
  defstruct [
    :author,
    :content,
    :description,
    :published_at,
    :source,
    :title,
    :summary,
    :url,
    :url_to_image,
    :entities,
    :sentiment
  ]
end
