defmodule ClientWeb.Router do
  use ClientWeb, :router

  import ClientWeb.AuthController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ClientWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", ClientWeb do
  #   pipe_through :browser

  #   # get "/", PageController, :index
  #   get "/", SessionController
  # end

  scope "/", ClientWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", SessionController, :new
    post "/", SessionController, :create
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
  end

  scope "/", ClientWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Boards
    get "/new_board", NewBoardController, :new
    post "/new_board", NewBoardController, :create

    # Lists and Tasks
    live "/boards", BoardLive.Index, :index
    live "/boards/new", BoardLive.Index, :new

    # Lists
    live "/boards/:board_id/lists/:list_id", BoardLive.Index, :edit

    # Tasks
    live "/boards/:board_id/lists/:list_id/tasks/:task_id", BoardLive.Index, :edit

    live "/boards/:board_id/lists/:list_id/tasks/:task_id/index", TaskLive.Index, :index
    live "/boards/:board_id/lists/:list_id/tasks/:task_id/edit", TaskLive.Index, :edit

    # Comments
    live "/boards/:board_id/lists/:list_id/tasks/:task_id/comments", TaskLive.Index, :new

    live "/boards/:board_id/lists/:list_id/tasks/:task_id/comments/:comment_id",
         TaskLive.Index,
         :edit
  end

  scope "/", ClientWeb do
    pipe_through [:browser]

    delete "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClientWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through :browser

  #     live_dashboard "/dashboard", metrics: ClientWeb.Telemetry
  #   end
  # end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  # if Mix.env() == :dev do
  #   scope "/dev" do
  #     pipe_through :browser

  #     forward "/mailbox", Plug.Swoosh.MailboxPreview
  #   end
  # end
end
