defmodule B.MixProject do
  use Mix.Project

  def project do
    [
      app: :bomberman,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {B.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.15"},
      {:bandit, "~> 1.1"},
      {:jason, "~> 1.4"},
      # {:eflambe, "~>0.3.0"},
      # {:ezprofiler, git: "https://github.com/nhpip/ezprofiler.git", app: false},
      # {:ezprofiler_deps, git: "https://github.com/nhpip/ezprofiler_deps.git"},
      {:websock_adapter, "~> 0.5.5"} 
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
