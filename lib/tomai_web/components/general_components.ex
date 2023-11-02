defmodule TomaiWeb.GeneralComponents do
  use Phoenix.Component

  def text_section(assigns) do
    ~H"""
    <div class="p-2">
      <h2 class="text-md font-medium"><%= @description %></h2>
    </div>
    """
  end
end
