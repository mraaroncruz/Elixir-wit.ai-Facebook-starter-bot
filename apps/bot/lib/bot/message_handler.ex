defmodule Bot.MessageHandler do
  use GenServer

  alias Bot.{Message, WeatherActions}

  @wit_access_token Application.get_env(:bot, :witai_api_key)

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def receive(:facebook, message) do
    %{"entry" => [%{ "messaging" => messages}]} = message
    Enum.each(messages, fn m ->
      msg = %Message{user_id: m["sender"]["id"], text: m["message"]["text"], timestamp: m["timestamp"]}
      GenServer.cast(__MODULE__, { :message, :facebook, msg })
    end)
  end

  def handle_cast({:message, provider, %Message{} = msg}, _state) do
    sesh = session_id(msg)
    Wit.run_actions(@wit_access_token, sesh, Bot.PizzaActions, msg.text)
    {:noreply, :ok}
  end

  defp session_id(msg), do: msg.user_id
end
