defmodule Tomai.News.AfrStream do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def connect(pid) do
    GenServer.call(__MODULE__, {:start_scrape, pid})
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:start_scrape, from}, _from, state) do
    Afr.start_afr_spider()

    state = Map.put(state, :pid, from)

    {:reply, [], state}
  end

  @impl true
  def handle_cast({:scraped_data, items}, state) do
    lv_pid = Map.get(state, :pid)

    updated_state =
      Map.put(state, :items, fn current_items ->
        current_items ++ items
      end)

    send(lv_pid, {:afr_stream, items})

    {:noreply, updated_state}
  end
end
