defmodule WebApi.WebhookController do
  use WebApi.Web, :controller

  require Logger

  def create(conn, params) do
    spawn fn ->
      Bot.MessageHandler.receive(:facebook, params)
    end
    text conn, "OK"
  end

  def challenge(conn, params) do
    case check_challenge(params) do
      {:ok, challenge} -> resp(conn, 200, challenge)
      :error           -> invalid_token(conn, params)
    end
  end

  defp check_challenge(%{
    "hub.mode" => "subscribe",
    "hub.verify_token" => token,
    "hub.challenge" => challenge} = params
  ) do
    app = Application.get_env(:web_api, WebApi.Endpoint)
    verify_token =  app[:challenge_verification_token]

    Logger.info "token #{token}"
    Logger.info "verify_token #{verify_token}"

    case token == verify_token do
      true -> {:ok, challenge}
      _ -> :error
    end
  end
  defp check_challenge(params), do: :error


  defp invalid_token(conn, params) do
    Logger.error("Bad request #{inspect(conn)} with params #{inspect(params)}")
    resp(conn, 500, "")
  end
end
