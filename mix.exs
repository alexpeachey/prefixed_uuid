defmodule PrefixedUuid.MixProject do
  use Mix.Project

  def project do
    [
      app: :prefixed_uuid,
      version: "1.0.0",
      elixir: "~> 1.17",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "PrefixedUUID",
      source_url: "https://github.com/alexpeachey/prefixed_uuid",
      homepage_url: "https://github.com/alexpeachey/prefixed_uuid"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:uniq, "~> 0.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    UUIDv7 identifiers base62 encoded with a prefix.
    Based on the blog post by Dan Schultzer:
    https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto
    """
  end

  defp package() do
    [
      name: "prefixed_uuid",
      files: ~w(lib mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/alexpeachey/prefixed_uuid",
        "Hex" => "https://hex.pm/packages/prefixed_uuid",
        "Documentation" => "https://hexdocs.pm/prefixed_uuid",
        "Dan Schultzer's Blog" =>
          "https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto"
      }
    ]
  end
end
