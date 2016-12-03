defmodule WebApi.PageController do
  use WebApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
