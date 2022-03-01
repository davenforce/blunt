defmodule BluntAbsinthe.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      version: @version,
      app: :blunt_absinthe,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/elixir-blunt/blunt_absinthe",
      package: [
        description: "Absinthe macros for `blunt` commands and queries",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/elixir-blunt/blunt_absinthe"}
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [blunt()] ++
      [
        # For testing
        {:etso, "~> 0.1.6", only: [:test]},
        {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
        {:elixir_uuid, "~> 1.6", only: [:dev, :test], override: true, hex: :uuid_utils},

        # generate docs
        {:ex_doc, "~> 0.28", only: :dev, runtime: false}
      ]
  end

  defp blunt do
    if Mix.env() == :prod do
      {:blunt, github: "blunt-elixir/blunt", ref: "reorg", sparse: "apps/blunt"}
    else
      {:blunt, path: "../blunt", override: true}
    end
  end
end
