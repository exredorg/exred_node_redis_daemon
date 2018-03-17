defmodule Exred.Node.RedisDaemon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exred_node_redis_daemon,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exred_library, git: "git@bitbucket.org:zsolt001/exred_library.git", app: false},
      {:redix, ">= 0.0.0"}
    ]
  end
end
