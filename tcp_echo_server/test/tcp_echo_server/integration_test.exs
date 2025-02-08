defmodule TCPEchoServer.IntegrationTest do
  use ExUnit.Case

  test "sends back the received data" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 4000, [:binary, active: false])

    assert :ok = :gen_tcp.send(socket, "Hello world\n")

    assert recv(socket) == "Hello world\n"
  end

  test "handles fragmented data" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 4000, [:binary, active: false])

    assert :ok = :gen_tcp.send(socket, "Hello")
    assert :ok = :gen_tcp.send(socket, " world\nand one more\n")
    assert :ok = :gen_tcp.send(socket, "and a third one\n")

    assert recv(socket) == "Hello world\nand one more\nand a third one\n"
  end

  test "handles multiple clients simultaneously" do
    tasks =
      for _ <- 1..5 do
        Task.async(fn ->
          {:ok, socket} = :gen_tcp.connect(~c"localhost", 4000, [:binary, active: false])

          assert :ok = :gen_tcp.send(socket, "Hello world\n")

          assert recv(socket) == "Hello world\n"
        end)
      end

    Task.await_many(tasks)
  end

  defp recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 500)
    recv(socket, data)
  end

  defp recv(socket, data) do
    case :gen_tcp.recv(socket, 0, 500) do
      {:ok, new_data} ->
        recv(socket, data <> new_data)

      {:error, :timeout} ->
        data

      {:error, reason} ->
        {:error, reason}
    end
  end
end
