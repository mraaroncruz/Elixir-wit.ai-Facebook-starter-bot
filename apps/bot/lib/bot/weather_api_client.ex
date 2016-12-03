defmodule Bot.WeatherAPIClient do
  def start_link(app_id) do
    Agent.start_link(fn -> %{app_id: app_id} end, name: __MODULE__)
  end

  def temperature(city, measurement \\ :c) do
    case data(city) do
      :error -> raise "Error!"
      w_data ->
        t = w_data["main"]["temp"]
        temp({measurement, t})
    end
  end

  def weather(city) do
    case data(city) do
      :error -> raise "Error!"
      w_data ->
        w_data["weather"]
        |> Enum.map(fn %{"description" => desc} -> desc end)
        |> Enum.join(", ")
    end
  end

  defp data(city) do
    res =
      url(city)
      |> HTTPotion.get

    case res do
      %HTTPotion.Response{status_code: 500} -> :error
      resp -> Poison.decode! resp.body
    end
  end

  defp temp({:c, kelvin}), do: Float.round(kelvin - 273.15)

  defp app_id do
    Agent.get(__MODULE__, fn %{app_id: id} -> id end)
  end

  defp url(city) do
    uri = "http://api.openweathermap.org/data/2.5/weather?q=" <> URI.encode(city) <> "&APPID=" <> app_id
    IO.puts(uri)
    uri
  end
end
