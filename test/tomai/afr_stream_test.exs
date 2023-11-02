defmodule Tomai.AfrStreamTest do
  alias Tomai.News.AfrStream
  use ExUnit.Case

  test "updates items in state" do
    initial_state = %{
      pid: "PID.333",
      items: [
        %{title: "Item 1", summary: "Summary 1", sentiment: "Positive"},
        %{title: "Item 2", summary: "Summary 2", sentiment: "Negative"}
      ]
    }

    new_items = [
      %{title: "Item 3", summary: "Summary 3", sentiment: "Neutral"},
      %{title: "Item 4", summary: "Summary 4", sentiment: "Positive"}
    ]

    expected_state = %{
      pid: "PID.333",
      items: [
        %{title: "Item 1", summary: "Summary 1", sentiment: "Positive"},
        %{title: "Item 2", summary: "Summary 2", sentiment: "Negative"},
        %{title: "Item 3", summary: "Summary 3", sentiment: "Neutral"},
        %{title: "Item 4", summary: "Summary 4", sentiment: "Positive"}
      ]
    }

    actual_state = AfrStream.update_items(initial_state, new_items)

    assert actual_state == expected_state
  end

  test "adds items to state when none exist prior" do
    initial_state = %{
      pid: "PID.333",
      items: []
    }

    new_items = [
      %{title: "Item 3", summary: "Summary 3", sentiment: "Neutral"},
      %{title: "Item 4", summary: "Summary 4", sentiment: "Positive"}
    ]

    expected_state = %{
      pid: "PID.333",
      items: [
        %{title: "Item 3", summary: "Summary 3", sentiment: "Neutral"},
        %{title: "Item 4", summary: "Summary 4", sentiment: "Positive"}
      ]
    }

    actual_state = AfrStream.update_items(initial_state, new_items)

    assert actual_state == expected_state
  end
end
