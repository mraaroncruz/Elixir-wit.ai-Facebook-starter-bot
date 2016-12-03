defmodule Bot.MessengerClient do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the the recipient
    * :recipient - the recipient to send the message to
    * :message - the message to send
  """
  @spec send(String.t, String.t) :: HTTPotion.Response.t
  def send(message, recipient) do
    res = manager.post(
      url: url,
      body: json_payload(recipient, message)
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  @doc """
  creates a payload to send to facebook
    * :recipient - the recipient to send the message to
    * :message - the message to send
  """
  def payload(recipient, message) do
    #message = message
    #|> Map.update!(:metadata, fn metadata ->
      #Poison.encode(message[:metadata]) |> elem(1)
    #end)
    %{
      recipient: %{id: recipient},
      message: message
    }
  end

  @doc """
  creates a json payload to send to facebook
    * :recipient - the recipient to send the message to
    * :message - the message to send
  """
  def json_payload(recipient, message) do
    p = payload(recipient, message)
    |> Poison.encode
    |> elem(1)
    IO.puts "Sending facebook message:\n#{inspect(p)}"
    p
  end

  @doc """
  return the url to hit to send the message
  """
  def url do
    query = "access_token=#{page_token}"
    "https://graph.facebook.com/v2.6/me/messages?#{query}"
  end

  defp page_token do
    Application.get_env(:facebook_messenger, :facebook_page_token)
  end

  defp manager do
    Application.get_env(:facebook_messenger, :request_manager) || FacebookMessenger.RequestManager
  end
end
