defmodule Exred.Node.RedisDaemonTest do
  use ExUnit.Case, async: false
  doctest Exred.Node.RedisDaemon

  use Exred.NodeTest, module: Exred.Node.RedisDaemon

  setup_all do
    start_node()
  end

  test "node starts", context do
    assert is_pid(context.pid)
  end

  test "PING succeeds", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["PING"])
    log("PING cmd result: #{inspect(result)}")
    assert result == {:ok, "PONG"}
  end

  test "SET command executes", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["SET", "hello", "world"])
    log("SET cmd result: #{inspect(result)}")
    assert result == {:ok, "OK"}
  end

  test "GET command executes", context do
    conn = String.to_atom(context.node.config.connection_name.value)
    result = Redix.command(conn, ["GET", "hello"])
    log("GET cmd result: #{inspect(result)}")
    assert result == {:ok, "world"}
  end

  def log(msg) do
    Logger.info("TEST OUTPUT: " <> msg)
  end
end
