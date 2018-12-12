defmodule Exred.Node.RedisDaemon do
  @moduledoc """
  This is a **daemon node**. It does not handle messages like a regular node.
  It is used for configuring and starting up a Redis connection pool that other
  nodes can use.
  """

  @name "Redis Daemon"
  @category "daemon"
  @info @moduledoc
  @config %{
    host: %{type: "string", value: "localhost"},
    port: %{type: "number", value: 6379, attrs: %{min: 0, max: 65535}},
    database: %{type: "number", value: 0},
    password: %{type: "string", value: nil},
    connection_name: %{type: "string", value: "redis"}
  }
  @ui_attributes %{right_icon: "loop"}

  use Exred.NodePrototype

  @impl true
  def daemon_child_specs(config) do
    redis_opts = [
      host: config.host.value,
      port: config.port.value,
      database: config.database.value,
      password: config.password.value
    ]

    # name cannot be a string
    conn_opts = [name: String.to_atom(config.connection_name.value)]

    # return the child spec for Redix
    Supervisor.child_spec({Redix, [redis_opts, conn_opts]}, [])
  end
end
