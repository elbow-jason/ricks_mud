defmodule RicksMud.Login do
  @welcome_msg """
  Welcome to Rick's Mud
  """
  @username_please "Please Enter Your Name: "

  def login_prompt(socket) do
    :gen_tcp.send(socket, @welcome_msg)
    login_loop(socket)
  end

  def parse_username([username]) do
    {:ok, username}
  end
  def parse_username(_) do
    {:error, :no_spaces_allowed}
  end

  def login_loop(socket) do
    :gen_tcp.send(socket, @username_please)
    receive do
      {:tcp, ^socket, raw_input} ->
        with :ok <- :ok,
          user_input      <- raw_input |> to_string,
          {:ok, parts}    <- RicksMud.Input.parse(user_input),
          {:ok, username} <- parse_username(parts)
        do
          # TODO
          # 1. prompt for authentication
          # 2. upon auth register process for a user
          #   (using the Registry module of Elixir 1.4)
          # in the user's process load user's state

          :gen_tcp.send(socket, "Sorry! It's under construction, #{username}!!!\n")
        else
          {:invalid, reason} ->
            :gen_tcp.send(socket, "Invalid Login: " <> to_string(reason) <> "\n")
            :gen_tcp.close(socket)
          {:error, :no_spaces_allowed} ->
            :gen_tcp.send(socket, "Username Should Not Contain Spaces\n")
            login_loop(socket)
          err ->
            IO.putsd("An unknown error occured #{inspect err}")
            :gen_tcp.send(socket, "The programmer made a grave error. Apologies.\n")
            :gen_tcp.close(socket)
            Process.exit(self(), :unknown_error)
        end
      err ->
        IO.warn "Failure before login  #{socket} #{inspect err}"
        :gen_tcp.close(socket)
        Process.exit(self(), :unknown_error)
    end
  end

end
