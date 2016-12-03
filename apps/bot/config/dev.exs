use Mix.Config

config :bot, :witai_api_key,  System.get_env("WITAI_API_KEY")

config :bot, :weather_app_id, System.get_env("WEATHER_API_KEY")

