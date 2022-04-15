defmodule ChatFCoinWeb.PageController do
  use ChatFCoinWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
