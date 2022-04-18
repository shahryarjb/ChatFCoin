defmodule ChatFCoin.Plugin.FacebookUserMessage do
  defmodule FacebookUserMessageBehaviour do
    @moduledoc """
      Define `FacebookUserMessageBehaviour` for `webhook` action.
      This module covers requireed `struct` and `behaviour, and it should be noted it is nested.
      This event is called by each user sending a message.
    """
    defstruct [:message_id, :message, :sender_id, :object, :conn]

    @type message() :: String.t()
    @type sender_id() :: integer()
    @type message_id() :: integer()
    @type object() :: String.t()
    @type ref() :: :on_facebook_user_message # Name of this event
    @type reason() :: map() | String.t() # output of state for this event
    @type conn() :: Plug.Conn.t()
    @type registerd_info() :: MishkaInstaller.PluginState.t() # information about this plugin on state which was saved
    @type state() :: %__MODULE__{message_id: message_id, message: message(), sender_id: sender_id(), object: object(), conn: conn()}
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
end
