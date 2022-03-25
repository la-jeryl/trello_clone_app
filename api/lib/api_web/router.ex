defmodule ApiWeb.Router do
  use ApiWeb, :router

  # # If you wish to also use Pow in your HTML frontend with session, then you
  # # should set the `Pow.Plug.Session method here rather than in the endpoint:
  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_flash
  #   plug Phoenix.LiveView.Flash
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  #   plug Pow.Plug.Session, otp_app: :my_app
  # end

  pipeline :api do
    plug :accepts, ["json"]
    plug ApiWeb.APIAuthPlug, otp_app: :api
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: ApiWeb.APIAuthErrorHandler
  end

  scope "/api", ApiWeb do
    pipe_through :api

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  scope "/api", ApiWeb do
    pipe_through [:api, :api_protected]

    # Your protected API endpoints here
    resources "/boards", BoardController, except: [:new, :edit]
  end

  # scope "/api", ApiWeb do
  #   pipe_through :api
  # end
end
