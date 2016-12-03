defmodule Bot.WeatherActions do
  use Wit.Actions
  require Logger

  alias Bot.WeatherAPIClient, as: Client

  @minimum_confidence 0.5

  def say(session, context, message) do
    Logger.warn inspect message
    Bot.MessengerClient.send(%{text: message.msg}, session)
  end

  def merge(session, context, message) do
    context = case get_intent(message) do
      "temperature" -> Map.put(context, :location, get_location(message))
      "weather"     -> Map.put(context, :location, get_location(message))
      "greet"       -> %{}
      nil           -> %{}
    end
    context
  end

  def error(session, context, error) do
    # Handle error
  end

  defaction get_forecast(session, context) do
    forecast = Client.weather(context.location)
    Map.put(context, :forecast, forecast)
  end

  defaction get_temperature(session, context) do
    temperature = Client.temperature(context.location)
    Map.put(context, :temperature, temperature)
  end

  defaction end_conversation(session, context) do
    %{}
  end

  defp get_location(message) do
    first_confident(message.entities["location"])
  end

  defp get_intent(message) do
    first_confident(message.entities["intent"])
  end

  defp first_confident(items) do
    match = Enum.find(items, fn %{"confidence" => c} ->
      c > @minimum_confidence
    end)
    match && match["value"]
  end
end
