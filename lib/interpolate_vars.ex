defmodule InterpolateVars do
  def start(rpn_list, variables, formulas) do
    {interpolated_fully, list} = do_start(rpn_list, [], variables, formulas)

    if(interpolated_fully) do
      {interpolated_fully, list}
    else
      {interpolated_fully, rpn_list}
    end
  end

  def do_start([], acc, _, _) do
    {true, acc}
  end

  def do_start([%{type: :variable, value: value} | rpn_list], acc, variables, formulas) do
    if(find_in_formulas(value, formulas)) do
      {false, []}
    else
      do_start(rpn_list, [variables[value] | acc], variables, formulas)
    end
  end

  def do_start([value | rpn_list], acc, variables, formulas) do
    do_start(rpn_list, [value | acc], variables, formulas)
  end

  def find_in_formulas(key, formulas) do
    Enum.find(formulas, fn {formula_name, _} -> key == formula_name end)
  end
end
