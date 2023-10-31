defmodule Tomai.News.AfrStream do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def connect(pid) do
    GenServer.call(__MODULE__, {:add_lv_pid, pid})
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_lv_pid, lv_pid}, _from, state) do
    state = Map.put(state, :lv_pid, lv_pid)

    {:reply, [], state}
  end

  @impl true
  def handle_cast({:scraped_data, items}, state) do
    updated_state =
      Map.put(state, :items, fn current_items ->
        current_items ++ items
      end)

    send(Map.get(state, :lv_pid), {:afr_stream, items})

    {:noreply, updated_state}
  end
end
