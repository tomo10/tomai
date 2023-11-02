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
    {:ok, %{items: []}}
  end

  @impl true
  def handle_call({:add_lv_pid, lv_pid}, _from, state) do
    state = Map.put(state, :lv_pid, lv_pid)

    {:reply, [], state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    # returns the :reply, result, and new_state
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:scraped_data, items}, state) do
    updated_state = update_items(state, items)

    send(Map.get(state, :lv_pid), {:afr_stream, items})

    {:noreply, updated_state}
  end

  def update_items(state, items) do
    Map.update(state, :items, [], fn existing_items -> existing_items ++ items end)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end
end
