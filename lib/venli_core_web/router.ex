defmodule VenliCoreWeb.Router do
  use VenliCoreWeb, :router

  pipeline :api do
    plug CORSPlug
    plug :accepts, ["json"]
  end

  pipeline :oauth do
    plug :fetch_session
    plug CORSPlug
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: VenliCore.Accounts.Guardian,
      error_handler: VenliCoreWeb.Guardian.ErrorHandler

    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug VenliCoreWeb.Plugs.EnsureAccessToken
  end

  # api routes
  scope "/api", VenliCoreWeb do
    pipe_through :api

    options "/*path", AuthController, :options

    scope "/auth" do
      post "/register", AuthController, :register
      post "/login", AuthController, :login
      post "/refresh", AuthController, :refresh
      post "/logout", AuthController, :logout
    end

    # OAuth routes 
    scope "/oauth" do
      pipe_through :oauth

      get "/:provider", OAuthController, :request
      get "/:provider/callback", OAuthController, :callback
    end

    scope "/user" do
      pipe_through :auth

      get "/", UserController, :profile
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:venli_core, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: VenliCoreWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
