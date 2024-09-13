defmodule PrefixedUUID do
  @moduledoc """
  Generates prefixed base62 encoded UUIDv7.
  https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto

  ## Examples

      @primary_key {:id, PrefixedUUID, prefix: "acct", autogenerate: true}
      @foreign_key_type PrefixedUUID
  """
  use Ecto.ParameterizedType
  alias PrefixedUUID.Base62UUID

  @type t :: String.t()

  @impl true
  @spec init(keyword()) :: map()
  def init(opts) do
    schema = Keyword.fetch!(opts, :schema)
    field = Keyword.fetch!(opts, :field)
    uniq = Uniq.UUID.init(schema: schema, field: field, version: 7, default: :raw, dump: :raw)

    case opts[:primary_key] do
      true ->
        prefix = Keyword.get(opts, :prefix) || raise "`:prefix` option is required"

        %{
          primary_key: true,
          schema: schema,
          prefix: prefix,
          uniq: uniq
        }

      _any ->
        %{
          schema: schema,
          field: field,
          uniq: uniq
        }
    end
  end

  @impl true
  @spec type(any()) :: :uuid
  def type(_params), do: :uuid

  @impl true
  @spec cast(nil | String.t(), map()) :: {:ok, String.t()} | :error
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, params) do
    with {:ok, prefix, _uuid} <- slug_to_uuid(data),
         {prefix, prefix} <- {prefix, prefix(params)} do
      {:ok, data}
    else
      _ -> :error
    end
  end

  @doc """
  Take an encode prefixed UUID string and split it into prefix and decoded UUID.

  ## Examples

      iex> PrefixedUUID.slug_to_uuid("test_3TUIKuXX5mNO2jSA41bsDx")
      {:ok, "test", "7232b37d-fc13-44c0-8e1b-9a5a07e24921"}
  """
  @spec slug_to_uuid(String.t()) :: {:ok, String.t(), String.t()} | :error
  def slug_to_uuid(string) do
    with [prefix, slug] <- String.split(string, "_"),
         {:ok, uuid} <- Base62UUID.decode(slug) do
      {:ok, prefix, uuid}
    else
      _ -> :error
    end
  end

  @spec prefix(map()) :: String.t()
  def prefix(%{primary_key: true, prefix: prefix}), do: prefix

  # If we deal with a belongs_to assocation we need to fetch the prefix from
  # the associations schema module
  def prefix(%{schema: schema, field: field}) do
    %{related: schema, related_key: field} = schema.__schema__(:association, field)

    case schema.__schema__(:type, field) do
      {:parameterized, __MODULE__, %{prefix: prefix}} -> prefix
      {:parameterized, {__MODULE__, %{prefix: prefix}}} -> prefix
    end
  end

  @impl true
  @spec dump(nil | String.t(), function(), map()) ::
          {:ok, nil} | {:ok, String.t()} | :error
  def dump(nil, _, _), do: {:ok, nil}

  def dump(slug, dumper, params) do
    case slug_to_uuid(slug) do
      {:ok, _prefix, uuid} -> Uniq.UUID.dump(uuid, dumper, params.uniq)
      :error -> :error
    end
  end

  @impl true
  @spec load(nil | String.t(), function(), map()) :: {:ok, nil} | {:ok, String.t()} | :error
  def load(data, loader, params) do
    case Uniq.UUID.load(data, loader, params.uniq) do
      {:ok, nil} -> {:ok, nil}
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid, params)}
      :error -> :error
    end
  end

  @spec uuid_to_slug(String.t(), map()) :: String.t()
  def uuid_to_slug(uuid, params) do
    "#{prefix(params)}_#{Base62UUID.encode(uuid)}"
  end

  @impl true
  @spec autogenerate(map()) :: String.t()
  def autogenerate(params) do
    uuid_to_slug(Uniq.UUID.autogenerate(params.uniq), params)
  end

  @spec generate(String.t()) :: String.t()
  def generate(prefix) do
    "#{prefix}_#{Base62UUID.encode(Uniq.UUID.uuid7())}"
  end

  @impl true
  @spec embed_as(atom(), map()) :: :dump | :self
  def embed_as(format, params), do: Uniq.UUID.embed_as(format, params.uniq)

  @impl true
  @spec equal?(nil | String.t(), nil | String.t(), map()) :: boolean()
  def equal?(nil, nil, _params), do: true
  def equal?(_a, nil, _params), do: false
  def equal?(nil, _b, _params), do: false

  def equal?(a, b, params) do
    with {:ok, prefix, uuid_a} <- slug_to_uuid(a),
         {:ok, ^prefix, uuid_b} <- slug_to_uuid(b) do
      Uniq.UUID.equal?(uuid_a, uuid_b, params.uniq)
    else
      _ -> Uniq.UUID.equal?(a, b, params.uniq)
    end
  end
end
