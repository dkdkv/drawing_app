defmodule DrawingAppWeb.Router do
  use DrawingAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DrawingAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_user_id
  end

  scope "/", DrawingAppWeb do
    pipe_through :browser
    live "/", CanvasLive
  end

  defp assign_user_id(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      user_id = "user_#{:rand.uniform(1000)}"
      conn
      |> put_session(:user_id, user_id)
      |> assign(:user_id, user_id)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  # scope "/", DrawingAppWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  # Other scopes may use custom stacks.
  # scope "/api", DrawingAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:drawing_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DrawingAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
