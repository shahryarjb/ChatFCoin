defmodule ChatFCoin.Plugin.FacebookSubscribe do
  defmodule FacebookSubscribeBehaviour do
    @moduledoc """
      Define `FacebookSubscribeBehaviour` for `webhook` action.
      This module covers requireed `struct` and `behaviour, and it should be noted it is nested.
      This event is called by each Facebook callback validating.
    """
    defstruct [:mod, :challenge, :verify_token, :conn]

    @type mod() :: String.t()
    @type challenge() :: String.t()
    @type verify_token() :: String.t()
    @type ref() :: :on_facebook_subscribe # Name of this event
    @type reason() :: map() | String.t() # output of state for this event
    @type conn() :: Plug.Conn.t()
    @type registerd_info() :: MishkaInstaller.PluginState.t() # information about this plugin on state which was saved
    @type state() :: %__MODULE__{mod: mod(), challenge: challenge(), verify_token: verify_token(), conn: conn()}
    @type t :: state() # help developers to keep elixir style
    @type optional_callbacks :: {:ok, ref(), registerd_info()} | {:error, ref(), reason()}

    @callback initial(list()) :: {:ok, ref(), list()} | {:error, ref(), reason()} # Register hook
    @callback call(state()) :: {:reply, state()} | {:reply, :halt, state()}  # Developer should decide what and Hook call function
    @callback stop(registerd_info()) :: optional_callbacks() # Stop of hook module
    @callback restart(registerd_info()) :: optional_callbacks() # Restart of hook module
    @callback start(registerd_info()) :: optional_callbacks() # Start of hook module
    @callback delete(registerd_info()) :: optional_callbacks() # Delete of hook module
    @callback unregister(registerd_info()) :: optional_callbacks() # Unregister of hook module
    @optional_callbacks stop: 1, restart: 1, start: 1, delete: 1, unregister: 1 # Developer can use this callbacks if he/she needs
  end

  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: FacebookSubscribeBehaviour,
      event: :on_facebook_subscribe,
      initial: []

    @spec initial(list()) :: {:ok, FacebookSubscribeBehaviour.ref(), list()}
    def initial(args) do
      event = %PluginState{name: "ChatFCoin.Plugin.FacebookSubscribe", event: Atom.to_string(@ref), priority: 1}
      Hook.register(event: event)
      {:ok, @ref, args}
    end

    @spec call(FacebookSubscribeBehaviour.t()) :: {:reply, FacebookSubscribeBehaviour.t()}
    def call(%FacebookSubscribeBehaviour{} = state) do
      {:reply, state}
    end
end

# alias ChatFCoin.Plugin.FacebookSubscribe.FacebookSubscribeBehaviour
# state = %FacebookSubscribeBehaviour{mod: mod, challenge: challenge, verify_token: verify_token, conn: conn}
# MishkaInstaller.Hook.call(event: "on_facebook_subscribe", state: state)
