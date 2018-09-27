defmodule RpnCalculate do
  def calculate([first_value | rest]) do
    action(first_value, rest, [])
  end

  def action(operator = %{type: :operator}, [], [operand_1, operand_2]) do
    apply_operator(operator, operand_1, operand_2)
  end

  def action(operator = %{type: :operator}, [next_item | rest], [operand_1, operand_2 | stack]) do
    result = apply_operator(operator, operand_1, operand_2)
    action(next_item, rest, [result | stack])
  end

  def action(variable, [next_item | rest], stack) do
    action(next_item, rest, [variable | stack])
  end

  def apply_operator(%{name: :multiply}, operand_1, operand_2) do
    o1 = to_decimal(operand_1)
    o2 = to_decimal(operand_2)
    Decimal.mult(o2, o1)
  end

  def apply_operator(%{name: :divide}, operand_1, operand_2) do
    o1 = to_decimal(operand_1)
    o2 = to_decimal(operand_2)
    Decimal.div(o2, o1)
  end

  def apply_operator(%{name: :plus}, operand_1, operand_2) do
    o1 = to_decimal(operand_1)
    o2 = to_decimal(operand_2)
    Decimal.add(o2, o1)
  end

  def apply_operator(%{name: :minus}, operand_1, operand_2) do
    o1 = to_decimal(operand_1)
    o2 = to_decimal(operand_2)
    Decimal.sub(o2, o1)
  end

  def apply_operator(%{name: :power}, operand_1, operand_2) do
    o1 = to_decimal(operand_1)
    o2 = to_decimal(operand_2)
    Power.power(o2, o1)
  end

  def to_decimal(%{name: :number, value: number_value}) do
    Decimal.new(number_value)
  end

  def to_decimal(number) do
    Decimal.new(number)
  end
end
