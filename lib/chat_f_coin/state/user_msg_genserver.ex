defmodule ChatFCoin.UserMsgDynamicGenserver do
  use GenServer
  require Logger
  alias ChatFCoin.{UserMsgDynamicSupervisor, UserMsgDynamicGenserver}

  defstruct [:user_id, :user_info, :user_answers, :last_try, :parent_pid, social_network: "facebook"]

  @type user_id() :: String.t()
  @type user_info() :: map()
  @type user_answers() :: [integer() | nil] | integer()
  @type last_try() :: NaiveDateTime.t()
  @type parent_pid() :: pid() | nil
  @type social_network() :: String.t()
  @type user_msg() :: %UserMsgDynamicGenserver{
    user_id: user_id(),
    user_info: user_info(),
    user_answers: user_answers(),
    last_try: last_try(),
    parent_pid: parent_pid(),
    social_network: social_network()
  }
  @type t :: user_msg()

  # Sender
  def start_link(args) do
    {id, type, parent_pid} = {Map.get(args, :id), Map.get(args, :type), Map.get(args, :parent_pid)}
    GenServer.start_link(__MODULE__, default(id, type, parent_pid), name: via(id, type))
  end

  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient,
      max_restarts: 4
    }
  end

  defp default(user_id, type, parent_pid) do
    %UserMsgDynamicGenserver{user_id: user_id, parent_pid: parent_pid, social_network: type, last_try: NaiveDateTime.utc_now()}
  end

  def push_call(%UserMsgDynamicGenserver{} = element) do
    case UserMsgDynamicSupervisor.start_job(%{id: element.user_id, type: element.social_network, parent_pid: element.parent_pid}) do
      {:ok, status, pid} ->
        GenServer.call(pid, {:push, status, element})
      {:error, result} ->  {:error, :push, result}
    end
  end

  def get(network: network_name) do
    case UserMsgDynamicSupervisor.get_user_msg_pid(network_name) do
      {:ok, :get_user_msg_pid, pid} -> GenServer.call(pid, {:pop, :network})
      {:error, :get_user_msg_pid} -> {:error, :get, :not_found}
    end
  end

  def get_all(network: network_name) do
    UserMsgDynamicSupervisor.running_imports(network_name) |> Enum.map(&get(network: &1.id))
  end

  def get_all() do
    UserMsgDynamicSupervisor.running_imports() |> Enum.map(&get(network: &1.id))
  end

  # Callbacks
  @impl true
  def init(%UserMsgDynamicGenserver{} = state) do
    if Mix.env == :test, do: MishkaInstaller.Database.Helper.get_parent_pid(state)
    Logger.info("#{Map.get(state, :user_id)} from #{Map.get(state, :social_network)} has started to be sending messages")
    {:ok, state, {:continue, {:user_evaluation}}}
  end

  @impl true
  def handle_call({:push, status, %UserMsgDynamicGenserver{} = element}, _from, %UserMsgDynamicGenserver{} = state) do
    element =
      Map.merge(element, %{user_answers: state.user_answers ++ element.user_answers})
    {:reply, element, element, {:continue, {:sending_message, status}}}
  end

  @impl true
  def handle_call({:pop, :network}, _from, %UserMsgDynamicGenserver{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_continue({:user_evaluation}, %UserMsgDynamicGenserver{} = state) do
    state =
      state
      |> Map.merge(%{
        user_info: ChatFCoin.Helper.HttpSender.get_user_info(state.user_id),
        last_try: NaiveDateTime.utc_now()
      })

    {:noreply, state}
  end

  @impl true
  def handle_continue({:sending_message, :add}, %UserMsgDynamicGenserver{} = state) do
    # TODO: send a message which includs help items and say hi with user first_name
    # TODO: check is there a problem in user's answer or not
    {:noreply, state}
  end

  @impl true
  def handle_continue({:sending_message, :edit}, %UserMsgDynamicGenserver{} = state) do
    # TODO: do user job based on user last answer number from user_answers list
    # TODO: if user send a duplicate number from user_answers list, tell him/her → wants to continue with last question or new request!?
    # TODO: if he/she selects new request maybe did before, so we need to change the list and delete all the previous number and put this just
    # TODO: if he wants to continue with last question, so send him the message or next selector
    # TODO: check is there a problem in user's answer or not
    # TODO: if he/her repeat pervious answer show him/her 3 btn like, { you want last question?, clean and start again? or continue}
    {:noreply, state}
  end

  defp via(id, value) do
    {:via, Registry, {UserMSGRegistry, id, value}}
  end

  def user_message(message) do
    %{
      "List of Coin with name" => 1,
      "List of Coin with id" => 2,
      "Clean my activity" => 3
    }[message]
  end
end
