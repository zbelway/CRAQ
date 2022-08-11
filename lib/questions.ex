defmodule Questions do
  @moduledoc """
    CRAQ questions and answers can be inputted directly into the terminal or called from this file
  """
@type text :: String.t()

@type option :: %{
  text: text(),
  complete_if_selected: boolean() | nil
}

@type question :: %{
  text: text(),
  option: option()
}

@type questions() :: list(question())

@spec questions :: questions()
def questions do
[
  %{options: [
    %{text: "No"},
    %{text: "how can anyone really know?", complete_if_selected: true}
  ],
  text: "Are you a human?"
  },
  %{options: [
    %{text: "No, why would I want to be different?"},
    %{text: "I want to be a real boy!"}
  ],
  text: "Do you wish you were?"
  }
]
end

def answers do
[
  %{},
  %{q0: 1},
  %{q0: 0, q1: 1},
  %{q0: 1, q1: 0},
  %{q0: 2, q1: 0},
  %{q0: 0, q1: 1, q2: 1},
  %{q1: 0, q2: 2}
]
end

end
