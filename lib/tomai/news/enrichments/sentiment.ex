defmodule Tomai.News.Enrichments.Sentiment do
  @moduledoc """
  Bumblebee based financial sentiment analysis.
  """
  alias Tomai.News.Article

  def predict(%Article{title: title, summary: summary} = article) do
    title_and_summary = title ++ summary
    %{predictions: preds} = Nx.Serving.batched_run(__MODULE__, title_and_summary)
    %{label: max_label} = Enum.max_by(preds, & &1.score)
    %{article | sentiment: max_label}
  end

  def predict(articles) when is_list(articles) do
    preds =
      Nx.Serving.batched_run(
        __MODULE__,
        Enum.map(articles, fn article ->
          article.title <> article.summary
        end)
      )

    Enum.zip_with(articles, preds, fn article, %{predictions: pred} ->
      %{label: max_label} = Enum.max_by(pred, & &1.score)
      %{article | sentiment: max_label}
    end)
  end

  def serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "ahmedrachid/FinancialBERT-Sentiment-Analysis"})

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "ahmedrachid/FinancialBERT-Sentiment-Analysis"})

    Bumblebee.Text.text_classification(model, tokenizer,
      defn_options: [compiler: EXLA],
      compile: [batch_size: 8, sequence_length: 128]
    )
  end
end
