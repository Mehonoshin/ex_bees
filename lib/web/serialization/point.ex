defimpl Poison.Encoder, for: Tuple do
  def encode({x, y}, options) do
    "{\"x\": #{x}, \"y\": #{y}}" |> Poison.Encoder.BitString.encode(options)
  end
end


