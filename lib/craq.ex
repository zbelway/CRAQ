defmodule Craq do
  @moduledoc """
  Documentation for `Craq`.
  """
@type results :: %{
pass: boolean(),
question_index: integer(),
error_message: map(),
terminus: boolean(),
answer: map()
}

@spec generate(map(), list(map())) :: list(map())
def generate(questions, answers) when is_list(answers) == true do
  Enum.map(answers, fn answer -> generate(questions, answer) end)
end

def generate(questions, answer) do
  results = init_results(answer)

  results = Enum.reduce(questions, results, &run_question(&1, &2))

  %{pass: Map.get(results, :pass), error_message: Map.get(results, :error_message)}
end

def init_results(answer) do
  %{
  pass: true,
  answers: answer,
  question_index: 0,
  error_message: %{},
  terminus: false
}
end

def run_question(_, %{terminus: already_done} = results) when already_done == true do
  if Map.get(results.answers, String.to_atom("q#{results.question_index}")) do
    results = Map.put(results, :pass, false)
    error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "was answered even though a previous response idicated that the questions were complete")
    Map.put(results, :error_message, error_message)
  else
    results
  end
end

def run_question(question, results) do
  answer_choice = Map.get(results.answers, String.to_atom("q#{results.question_index}"), :blank_answer)

  results = get_question_option(question, results, answer_choice)

  Map.put(results, :question_index, results.question_index + 1)
end

def get_question_option(_, results, answer_choice) when answer_choice == :blank_answer do
  results = Map.put(results, :pass, false)
  error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "was not answered")
  Map.put(results, :error_message, error_message)
end

def get_question_option(question, results, answer_choice) do
  option = Enum.at(question.options, answer_choice)
  evaluate_option(results, option)
end

def evaluate_option(results, option) when option == nil do
  results = Map.put(results, :pass, false)
  error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "has an answer that is not on the list of valid answers")
  Map.put(results, :error_message, error_message)
end

def evaluate_option(results, option) do
  if Map.get(option, :complete_if_selected) do
    Map.put(results, :terminus, true)
  else
    results
  end
end

end
