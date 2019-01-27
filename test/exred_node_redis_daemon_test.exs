defmodule Exred.Node.RedisDaemonTest do
  use ExUnit.Case, async: false
  doctest Exred.Node.RedisDaemon
  require Logger

  @node_module Exred.Node.RedisDaemon
  setup_all do
    node_attributes = @node_module.attributes()
    assert is_map(node_attributes)

    node =
      node_attributes
      |> Map.put(:module, @node_module)
      |> Map.put(:id, @node_module)

    if node.category == "daemon" do
      # start child processes
      child_specs = node.module.daemon_child_specs(node.config)
      assert is_list(child_specs)

      log("Starting #{length(child_specs)} child process(es)")

      child_specs
      |> Enum.each(&start_supervised!/1)
    end

    # create a dummy event sending function
    send_event_fun = fn event, payload ->
      log("EVENT: #{inspect(event)} | PAYLOAD: #{inspect(payload)}")
    end

    # start the node
    start_args = [node.id, node.config, send_event_fun]
    child_spec = Supervisor.child_spec({node.module, start_args}, id: node.id)
    pid = start_supervised!(child_spec)

    [pid: pid, node: node]
  end

  test "node starts", context do
    assert context.pid
  end

  test "PING succeeds", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["PING"])
    log("PING cmd result: #{inspect(result)}")
    assert result = {:ok, "PONG"}
  end

  test "SET command executes", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["SET", "hello", "world"])
    log("SET cmd result: #{inspect(result)}")
    assert result = {:ok, "world"}
  end

  test "GET command executes", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["GET", "hello"])
    log("GET cmd result: #{inspect(result)}")
    assert result
  end

  def log(msg) do
    Logger.info("TEST OUTPUT: " <> msg)
  end
end
