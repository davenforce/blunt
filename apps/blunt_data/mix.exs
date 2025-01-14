defmodule BluntData.MixProject do
  use Mix.Project

  @version "0.1.0-rc1"

  def project do
    [
      app: :blunt_data,
      version: @version,
      elixir: "~> 1.12",
      #
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      #
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
    [
      {:ecto, "~> 3.7"},
      # Optional deps.
      {:faker, "~> 0.17.0", optional: true},
      {:ex_machina, "~> 2.7", optional: true},

      # For testing
      {:elixir_uuid, "~> 1.6", only: [:dev, :test], override: true, hex: :uuid_utils}
    ]
  end
end
