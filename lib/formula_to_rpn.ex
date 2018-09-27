defmodule FormulaToRpn do
  def start(tokens) do
    %{output_queue: output_queue, operator_stack: operator_stack} =
      Enum.reduce(tokens, %{output_queue: [], operator_stack: []}, &shunt/2)

    Enum.concat(Enum.reverse(output_queue), operator_stack)
  end

  defp shunt(number = %Token{type: :number}, %{
         output_queue: output_queue,
         operator_stack: operator_stack
       }) do
    %{output_queue: [number | output_queue], operator_stack: operator_stack}
  end

  defp shunt(variable = %Token{type: :variable}, %{
         output_queue: output_queue,
         operator_stack: operator_stack
       }) do
    %{
      output_queue: [variable | output_queue],
      operator_stack: operator_stack
    }
  end

  defp shunt(operator = %Token{name: :paren_start}, acc) do
    %{output_queue: acc.output_queue, operator_stack: [operator | acc.operator_stack]}
  end

  defp shunt(operator = %Token{name: :paren_end}, acc) do
    ShuntRightParen.shunt(operator, acc)
  end

  defp shunt(operator = %Token{type: :operator}, acc) do
    ShuntOperators.shunt(operator, acc)
  end
end

defmodule ShuntOperators do
  def shunt(
        operator = %Token{type: :operator, precidence: precidence},
        acc = %{
          operator_stack: [
            previous_operator = %Token{type: :operator, precidence: previous_precidence}
            | operator_stack_rest
          ]
        }
      )
      when previous_precidence > precidence and previous_precidence != nil and precidence != nil do
    shunt(operator, %{
      operator_stack: operator_stack_rest,
      output_queue: [previous_operator | acc.output_queue]
    })
  end

  def shunt(
        operator = %Token{type: :operator, precidence: precidence},
        acc = %{
          operator_stack: [
            previous_operator = %Token{
              type: :operator,
              precidence: previous_precidence,
              association: :left
            }
            | operator_stack_rest
          ]
        }
      )
      when previous_precidence == precidence and previous_precidence != nil and precidence != nil do
    shunt(operator, %{
      operator_stack: operator_stack_rest,
      output_queue: [previous_operator | acc.output_queue]
    })
  end

  def shunt(operator, acc) do
    %{operator_stack: [operator | acc.operator_stack], output_queue: acc.output_queue}
  end
end

defmodule ShuntRightParen do
  def shunt(_, acc = %{operator_stack: [%Token{name: :paren_start} | op_stack_rest]}) do
    %{output_queue: acc.output_queue, operator_stack: op_stack_rest}
  end

  def shunt(operator, acc = %{operator_stack: [previous_operator | op_stack_rest]}) do
    shunt(operator, %{
      output_queue: [previous_operator | acc.output_queue],
      operator_stack: op_stack_rest
    })
  end
end
