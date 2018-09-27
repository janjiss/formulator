defmodule Token do
  defstruct type: nil, value: nil, name: nil, token_closed: nil, association: nil, precidence: nil
end

defmodule FormulaTokenizer do
  def tokenize(formula) do
    formula |> String.split("") |> Enum.reduce([], &do_tokenize/2)
  end

  defp do_tokenize("[", acc) do
    [%Token{type: :variable, value: "", token_closed: false} | acc]
  end

  defp do_tokenize("]", [previous_token = %{type: :variable, token_closed: false} | tail]) do
    [%Token{previous_token | token_closed: true} | tail]
  end

  defp do_tokenize(e, [
         previous_token = %{type: :variable, value: value, token_closed: false} | tail
       ]) do
    [%Token{previous_token | value: value <> e} | tail]
  end

  defp do_tokenize("-", acc) do
    [%Token{name: :minus, type: :operator, association: :left, precidence: 2} | acc]
  end

  defp do_tokenize("+", acc) do
    [%Token{name: :plus, type: :operator, association: :left, precidence: 2} | acc]
  end

  defp do_tokenize("/", acc) do
    [%Token{name: :divide, type: :operator, association: :left, precidence: 3} | acc]
  end

  defp do_tokenize("*", acc) do
    [%Token{name: :multiply, type: :operator, association: :left, precidence: 3} | acc]
  end

  defp do_tokenize("^", acc) do
    [%Token{name: :power, type: :operator, association: :right, precidence: 4} | acc]
  end

  defp do_tokenize(" ", acc) do
    acc
  end

  defp do_tokenize("", acc) do
    acc
  end

  defp do_tokenize("(", acc) do
    [%Token{type: :operator, name: :paren_start} | acc]
  end

  defp do_tokenize(")", acc) do
    [%Token{type: :operator, name: :paren_end} | acc]
  end

  defp do_tokenize(a, [previous_token = %{name: :number, value: previous_value} | head]) do
    [%Token{previous_token | value: previous_value <> a} | head]
  end

  defp do_tokenize(a, acc) do
    [%Token{type: :number, name: :number, value: a} | acc]
  end
end

defmodule Formulator do
  def start(formulas, variables \\ %{}) do
    formula_tokens =
      Enum.map(formulas, fn {formula_name, formula} ->
        tokens = FormulaTokenizer.tokenize(formula)
        {formula_name, Enum.reverse(tokens)}
      end)

    do_interpolate(formula_tokens, variables, %{}, formulas)
  end

  defp do_interpolate([], _, formula_results, _) do
    formula_results
  end

  defp do_interpolate([{formula_name, tokens} | rest], variables, formula_results, formulas) do
    {interpolation_succeeded, interpolated_tokens} =
      FormulaToRpn.start(tokens)
      |> InterpolateVars.start(Map.merge(variables, formula_results), formulas)

    if(interpolation_succeeded) do
      do_interpolate(
        rest,
        variables,
        Map.merge(formula_results, %{
          formula_name => RpnCalculate.calculate(interpolated_tokens |> Enum.reverse())
        }),
        remove_formulas(formula_name, formulas)
      )
    else
      do_interpolate(rest ++ [{formula_name, tokens}], variables, formula_results, formulas)
    end
  end

  defp remove_formulas(formula_name, formulas) do
    Enum.filter(formulas, fn {name, _} -> formula_name != name end)
  end
end
