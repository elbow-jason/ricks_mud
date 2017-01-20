defmodule RicksMud.Server do

  @tcp_options [:binary] ++ [
    packet: 2,
    active: false,
    reuseaddr: true,
  ]
  @default_port 3322

  def start_link do
    pid = spawn_link(__MODULE__, :server, [@default_port])
    {:ok, pid}
  end

  def server(port) do
    # if we were worried about scale we could spawn a handful/bunch
    # of processes that would accept(socket) and
    # spawn the login processes, but this is not a concern for our
    # mud until we become "web scale".
    {:ok, socket} = :gen_tcp.listen(port, [{:packet, :line}, {:reuseaddr, true}])
    IO.puts("socket #{inspect socket} listening on #{port}")
    listen_loop(socket)
  end

  def listen_loop(socket) do
    {:ok, active_socket} = :gen_tcp.accept(socket)
    handler = spawn(RicksMud.Login, :login_prompt, [active_socket])
    :ok = :gen_tcp.controlling_process(active_socket, handler)
    listen_loop(socket)
  end


end
