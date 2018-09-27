defmodule RpnPrinter do
  def print(a) do
    IO.inspect(Enum.map(a, &to_s/1) |> Enum.join(" "))
    a
  end

  def to_s(%{name: :multiply}) do
    "*"
  end

  def to_s(%{name: :divide}) do
    "/"
  end

  def to_s(%{name: :plus}) do
    "+"
  end

  def to_s(%{name: :minus}) do
    "-"
  end

  def to_s(%{name: :power}) do
    "^"
  end

  def to_s(a) do
    a
  end
end
