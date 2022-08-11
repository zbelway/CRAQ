defmodule Craq do
  @moduledoc """
  Documentation for `Craq`.
  """

  @doc """
    Change Request Acceptance Questions are inputted along with the users answer.
    This module validates the user's answers and responds either with a pass or eith an error message.

  ## Examples

    iex> questions = [%{text: "What is the meaning of life?",
    ...>  options: [%{ text: "41" }, %{ text: "42", complete_if_selected: true }]},
    ...>  %{text: "Why did you not select 42 as the answer to the previous question?",
    ...>  options: [%{ text: "I'd far rather be happy than right any day" },%{ text: "I don't get that reference" }]}]
    iex> answers = %{q0: 0, q1: 0}
    iex> Craq.generate(questions, answers)
    %{pass: true}

    iex> questions = Questions.questions
    iex> answers = Questions.answers
    iex> Craq.generate(questions, answers)
    [
      %{
        error_message: %{q0: "was not answered", q1: "was not answered"},
        pass: false
      },
      %{pass: true},
      %{pass: true},
      %{
        error_message: %{
          q1: "was answered even though a previous response idicated that the questions were complete"
        },
        pass: false
      },
      %{
        error_message: %{
          q0: "has an answer that is not on the list of valid answers"
        },
        pass: false
      },
      %{pass: true},
      %{error_message: %{q0: "was not answered"}, pass: false}
    ]
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
  output_results(results)
end

defp output_results(results) when results.pass == true do
  %{pass: Map.get(results, :pass)}
end

defp output_results(results) do
  %{pass: Map.get(results, :pass), error_message: Map.get(results, :error_message)}
end

defp init_results(answer) do
  %{
  pass: true,
  answers: answer,
  question_index: 0,
  error_message: %{},
  terminus: false
}
end

defp run_question(_, %{terminus: already_done} = results) when already_done == true do
  if Map.get(results.answers, String.to_atom("q#{results.question_index}")) do
    results = Map.put(results, :pass, false)
    error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "was answered even though a previous response idicated that the questions were complete")
    Map.put(results, :error_message, error_message)
  else
    results
  end
end

defp run_question(question, results) do
  answer_choice = Map.get(results.answers, String.to_atom("q#{results.question_index}"), :blank_answer)

  results = get_question_option(question, results, answer_choice)

  Map.put(results, :question_index, results.question_index + 1)
end

defp get_question_option(_, results, answer_choice) when answer_choice == :blank_answer do
  results = Map.put(results, :pass, false)
  error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "was not answered")
  Map.put(results, :error_message, error_message)
end

defp get_question_option(question, results, answer_choice) do
  option = Enum.at(question.options, answer_choice)
  evaluate_option(results, option)
end

defp evaluate_option(results, option) when option == nil do
  results = Map.put(results, :pass, false)
  error_message = Map.put(results.error_message, String.to_atom("q#{results.question_index}"), "has an answer that is not on the list of valid answers")
  Map.put(results, :error_message, error_message)
end

defp evaluate_option(results, option) do
  if Map.get(option, :complete_if_selected) do
    Map.put(results, :terminus, true)
  else
    results
  end
end

end
