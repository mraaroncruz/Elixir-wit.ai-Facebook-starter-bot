defmodule Bot.PizzaActions do
  use Wit.Actions
  require Logger

  @minimum_confidence 0.5

  def say(session, context, message) do
    Logger.warn inspect message
    Bot.MessengerClient.send(%{text: message.msg}, session)
  end

  def merge(session, context, message) do
    context = case get_intent(message) do
      "pizza_size" ->
        best = first_confident(message.entities["pizza_size"])
        Map.put(context, :pizza_size, best)
      "pizza_type" ->
        best = first_confident(message.entities["pizza_type"])
        Map.put(context, :pizza_type, best)
      "pizza"      -> %{}
      "greet"      -> %{}
      nil          -> %{}
    end
    context
  end

  def error(session, context, error) do
    # Handle error
    context
  end

  defaction end_conversation(session, context) do
    %{}
  end

  defp get_intent(message) do
    first_confident(message.entities["intent"])
  end

  defp entity(e, entities) do
    entities[e]
  end

  defp first_confident(nil), do: nil
  defp first_confident(items) do
    match = Enum.find(items, fn %{"confidence" => c} ->
      c > @minimum_confidence
    end)
    match && match["value"]
  end
end
