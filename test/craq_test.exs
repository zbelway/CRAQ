defmodule CraqTest do
  use ExUnit.Case
  doctest Craq

  describe "it is invalid with no answers" do
    def test1 do
      questions = [%{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] }]
      answers = %{}
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q0: "was not answered"}
    end
  end

  describe "it is invalid with nil answers" do
    def test2 do
      questions = [%{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] }]
      answers = nil
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q0: "was not answered"}
    end
  end

  describe "errors are added for all questions" do
    def test3 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = nil
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q0: "was not answered", q1: "was not answered"}
    end
  end

  describe "it is valid when an answer is given" do
    def test4 do
      questions = [%{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] }]
      answers = %{q0: 0}
      test = Craq.generate(questions, answers)
      assert test.pass
    end
  end

  describe "it is valid when there are multiple options and the last option is chosen" do
    def test5 do
      questions = [%{ text: 'q1', options: [%{ text: 'yes' }, %{ text: 'no' }, %{ text: 'maybe' }] }]
      answers = %{q0: 2}
      test = Craq.generate(questions, answers)
      assert test.pass
    end
  end

  describe "it is invalid when the answer is not one of the valid answers" do
    def test6 do
      questions = [%{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] }]
      answers = %{q0: 2}
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q0: "has an answer that is not on the list of valid answers"}
    end
  end

  describe "it is invalid when not all the questions are answered" do
    def test7 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 0}
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q1: "was not answered"}
    end
  end

  describe "it is valid when all the questions are answered" do
    def test8 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'an option' }, %{ text: 'another option' }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 0, q1: 0}
      test = Craq.generate(questions, answers)
      assert test.pass
    end
  end

  describe "it is valid when questions after complete_if_selected are not answered" do
    def test9 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'yes' }, %{ text: 'no', complete_if_selected: true }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 1}
      test = Craq.generate(questions, answers)
      assert test.pass
    end
  end

  describe "it is invalid when questions after complete_if_selected are answered" do
    def test10 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'yes' }, %{ text: 'no', complete_if_selected: true }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 1, q1: 0}
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q1: "was answered even though a previous response indicated that the questions were complete"}
    end
  end

  describe "it is valid if complete_if_selected is not a terminal answer and further questions are answered" do
    def test11 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'yes' }, %{ text: 'no', complete_if_selected: true }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 0, q1: 1}
      test = Craq.generate(questions, answers)
      assert test.pass
    end
  end

  describe "it is invalid if complete_if_selected is not a terminal answer and further questions are not answered" do
    def test12 do
      questions = [
        %{ text: 'q1', options: [%{ text: 'yes' }, %{ text: 'no', complete_if_selected: true }] },
        %{ text: 'q2', options: [%{ text: 'an option' }, %{ text: 'another option' }] }
      ]
      answers = %{q0: 0}
      test = Craq.generate(questions, answers)
      refute test.pass
      assert test.error_message == %{q1: "was not answered"}
    end
  end
end
