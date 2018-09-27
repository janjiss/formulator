defmodule Power do
  def power(number, power_of) do
    start(number, number, Decimal.to_integer(power_of))
  end

  def start(number, _, 1) do
    number
  end

  def start(number, original, power_of) do
    start(Decimal.mult(number, original), original, power_of - 1)
  end
end
