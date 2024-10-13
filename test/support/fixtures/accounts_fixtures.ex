defmodule KeepTrack.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KeepTrack.Accounts` context.
  """

  @doc """
  Generate a unique users email.
  """
  def unique_users_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique users google_id.
  """
  def unique_users_google_id, do: "some google_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a users.
  """
  def users_fixture(attrs \\ %{}) do
    {:ok, users} =
      attrs
      |> Enum.into(%{
        access_token: "some access_token",
        email: unique_users_email(),
        google_id: unique_users_google_id(),
        name: "some name",
        refresh_token: "some refresh_token",
        token_expires_at: ~U[2024-10-12 20:18:00Z]
      })
      |> KeepTrack.Accounts.create_users()

    users
  end
end
