defmodule PrefixedUUID.Base62UUID do
  @moduledoc """
  Encodes and decodes base62 UUIDs.
  """
  @base62_uuid_length 22
  @uuid_length 32
  @base62_alphabet ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  @spec encode(String.t()) :: String.t()
  def encode(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> base62_encode()
    |> String.pad_leading(@base62_uuid_length, "0")
  end

  @spec decode(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(string) do
    with {:ok, number} <- base62_decode(string) do
      number_to_uuid(number)
    end
  end

  @spec number_to_uuid(integer()) :: {:ok, String.t()} | {:error, String.t()}
  defp number_to_uuid(number) do
    number
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(@uuid_length, "0")
    |> case do
      <<g1::binary-size(8), g2::binary-size(4), g3::binary-size(4), g4::binary-size(4),
        g5::binary-size(12)>> ->
        {:ok, "#{g1}-#{g2}-#{g3}-#{g4}-#{g5}"}

      other ->
        {:error, "got invalid base62 uuid; #{inspect(other)}"}
    end
  end

  @spec base62_encode(integer()) :: String.t()
  for {digit, idx} <- Enum.with_index(@base62_alphabet) do
    defp base62_encode(unquote(idx)), do: unquote(<<digit>>)
  end

  defp base62_encode(number) do
    base62_encode(div(number, unquote(length(@base62_alphabet)))) <>
      base62_encode(rem(number, unquote(length(@base62_alphabet))))
  end

  @spec base62_decode(String.t()) :: {:ok, integer()} | {:error, String.t()}
  defp base62_decode(string) do
    string
    |> String.split("", trim: true)
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, {0, 0}}, fn char, {:ok, {acc, step}} ->
      case decode_base62_char(char) do
        {:ok, number} ->
          {:cont,
           {:ok, {acc + number * Integer.pow(unquote(length(@base62_alphabet)), step), step + 1}}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, {number, _step}} -> {:ok, number}
      {:error, error} -> {:error, error}
    end
  end

  @spec decode_base62_char(String.t()) :: {:ok, integer()} | {:error, String.t()}
  for {digit, idx} <- Enum.with_index(@base62_alphabet) do
    defp decode_base62_char(unquote(<<digit>>)), do: {:ok, unquote(idx)}
  end

  defp decode_base62_char(char), do: {:error, "got invalid base62 character; #{inspect(char)}"}
end
