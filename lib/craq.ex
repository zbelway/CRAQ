defmodule Craq do
  @moduledoc """
  Documentation for `Craq`.
  """
@type results :: %{
questions_index: integer(),
error_message: map(),
terminus: boolean(),
answer: map()
}

def generate(questions, answers) do
  run_answer(questions, answers)
end

def run_answer(questions, answer) do
  results = %{
    question_index: 0,
    error_message: %{},
    terminus: false,
    answer: answer
  }
  Enum.each(questions, fn question -> run_question(question, results) end)
  if Enum.empty?(results.error_message) do
    IO.puts("passed!")
  else
    IO.puts(results.error_message)
  end
end

def run_question(question, results) do
  {answer_choice, results} = get_answer_tuple(results)
  check_for_errors(question, answer_choice, results)
  Map.put(results, :question_index, results.question_index + 1)
end

@spec get_answer_tuple(results()) :: tuple()
def get_answer_tuple(results) do
   ans = Map.get(results.answer, String.to_atom("q#{results.question_index}"))
   {ans, results}
end

def check_for_errors(question, answer_choice, results) do
  error = false
  if results.terminus == true do
    error = "was answered even though a previous response idicated that the questions were complete"
  end

  case get_question_option(question.options, answer_choice) do

    nil ->
      error = "has an answer that is not on the list of valid answers"

    :blank_answer -> error = "was not answered"

    other_option -> results =
      if Map.get(other_option, :complete_if_selected) do
        Map.put(results, :terminus, true)
      end
  end

  if error do
    Map.put(results.error_message, String.to_atom("q#{results.questions_index}"), error)
  end

  Map.put(results, :error_message, results.error_message)
end

def get_question_option(_, :blank_answer) do
  :blank_answer
end

def get_question_option(options, answer_choice) do
  Enum.at(options, answer_choice)
end

end
