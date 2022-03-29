defmodule Api.AuthorizationTest do
  use ExUnit.Case
  import Api.Authorization, except: [can: 1]
  alias Api.Boards.Board
  alias Api.Comments.Comment

  def can("read" = role) do
    grant(role)
    |> show(Board)
    |> create(Comment)
  end

  test "role can read resource" do
    assert can("read") |> show?(Board)
  end

  test "role can create resource" do
    assert can("read") |> create?(Comment)
  end

  test "role can not update resource" do
    refute can("read") |> update?(Board)
  end

  test "role can not delete resource" do
    refute can("read") |> delete?(Board)
  end
end
