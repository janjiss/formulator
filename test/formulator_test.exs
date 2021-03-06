defmodule FormulatorTest do
  use ExUnit.Case
  doctest Formulator

  test "recursive formulas" do
    formulas = [
      {"First Formula", "3 + [Second Formula] * 2 * ( 1 - 5 ) ^ 2 ^ 3"},
      {"Second Formula", "[Variable 1] + 2"},
      {"Third Formula", "[A]+[B]+[C]+[D]+[E]+[F]+[G]+[H]+[J]+[K]"}
    ]

    variables = %{
      "A" => 10,
      "B" => 42,
      "C" => 10,
      "D" => 12,
      "E" => 100,
      "F" => 20,
      "G" => 10,
      "H" => 10,
      "J" => 10,
      "K" => 10,
      "Variable 1" => 2
    }

    expected_result = %{
      "First Formula" => Decimal.new(524_291),
      "Second Formula" => Decimal.new(4),
      "Third Formula" => Decimal.new(234)
    }

    assert(Formulator.start(formulas, variables) == expected_result)
  end
end
