defmodule ChatFCoin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ChatFCoin.Repo,
      # Start the Telemetry supervisor
      ChatFCoinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChatFCoin.PubSub},
      # Start the Endpoint (http/https)
      ChatFCoinWeb.Endpoint,
      # Start a worker by calling: ChatFCoin.Worker.start_link(arg)
      # {ChatFCoin.Worker, arg}
      {Finch, name: MyHttpClient},
      %{id: ChatFCoin.Plugin.FacebookSubscribe, start: {ChatFCoin.Plugin.FacebookSubscribe, :start_link, [[]]}},
      %{id: ChatFCoin.Plugin.FacebookUserMessage, start: {ChatFCoin.Plugin.FacebookUserMessage, :start_link, [[]]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatFCoin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatFCoinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
