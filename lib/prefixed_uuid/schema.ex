defmodule PrefixedUUID.Schema do
  @moduledoc """
  Use this instead of Ecto.Schema

  ## Examples

      use PrefixedUUID.Schema, prefix: "user"
  """
  defmacro __using__(opts \\ []) do
    prefix = Keyword.fetch!(opts, :prefix)

    quote do
      use Ecto.Schema

      @primary_key {:id, PrefixedUUID, prefix: unquote(prefix), autogenerate: true}
      @foreign_key_type PrefixedUUID

      @type t :: %__MODULE__{}

      @spec prefix() :: String.t()
      def prefix, do: unquote(prefix)

      @spec generate_id() :: PrefixedUUID.t()
      def generate_id, do: PrefixedUUID.generate(unquote(prefix))
    end
  end
end
