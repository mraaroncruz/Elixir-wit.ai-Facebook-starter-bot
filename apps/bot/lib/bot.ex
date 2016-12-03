defmodule Bot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Bot.MessageHandler, []),
      worker(Bot.WeatherAPIClient, [Application.get_env(:bot, :weather_app_id)]),
    ]

    opts = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
