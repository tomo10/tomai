defmodule Tomai.News.AfrStream do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # this will receive the live view pid to connect to the liveview
  def connect(pid) do
    GenServer.call(__MODULE__, {:connect, pid})
  end

  @impl true
  def init(_initial_state) do
    {:ok, []}
  end

  @impl true
  def handle_call(:next_headlines, from, socket) do
    # maybe here we run spider and return the headlines
    Crawly.Engine.start_spider(Afr)
    {:reply, socket}
  end
end
