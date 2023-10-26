defmodule TomaiWeb.PageController do
  use TomaiWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def scraper(conn, _params) do
    render(conn, :scraper)
  end
end
