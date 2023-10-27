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
    {:ok, :unused_state}
  end

  @impl true
  def handle_call({:connect, from}, _from, _unused_state) do
    # maybe here we run spider and return the headlines
    # Crawly.Engine.start_spider(Afr)

    {:reply, [], :unused_state}
  end

  # @impl true
  # def handle_info({:scraped_data, data}, _state) do
  #   send(pid, {:afr_stream, data})
  #   IO.inspect(data, label: "--------------- data in afr stream handle info --------------")
  #   {:noreply, data}
  # end

  @impl true
  def handle_cast({:scraped_data, new_state}, :unused_state) do
    pid = Process.whereis(TomaiWeb.ScraperLive.Index)
    # HOW do i get this liveView's pid?!?!!?!?
    send(pid, {:afr_stream, new_state})

    {:noreply, new_state}
  end
end
