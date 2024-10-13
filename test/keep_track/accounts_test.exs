defmodule KeepTrack.AccountsTest do
  use KeepTrack.DataCase

  alias KeepTrack.Accounts

  describe "user" do
    alias KeepTrack.Accounts.Users

    import KeepTrack.AccountsFixtures

    @invalid_attrs %{name: nil, google_id: nil, email: nil, access_token: nil, refresh_token: nil, token_expires_at: nil}

    test "list_user/0 returns all user" do
      users = users_fixture()
      assert Accounts.list_user() == [users]
    end

    test "get_users!/1 returns the users with given id" do
      users = users_fixture()
      assert Accounts.get_users!(users.id) == users
    end

    test "create_users/1 with valid data creates a users" do
      valid_attrs = %{name: "some name", google_id: "some google_id", email: "some email", access_token: "some access_token", refresh_token: "some refresh_token", token_expires_at: ~U[2024-10-12 20:18:00Z]}

      assert {:ok, %Users{} = users} = Accounts.create_users(valid_attrs)
      assert users.name == "some name"
      assert users.google_id == "some google_id"
      assert users.email == "some email"
      assert users.access_token == "some access_token"
      assert users.refresh_token == "some refresh_token"
      assert users.token_expires_at == ~U[2024-10-12 20:18:00Z]
    end

    test "create_users/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_users(@invalid_attrs)
    end

    test "update_users/2 with valid data updates the users" do
      users = users_fixture()
      update_attrs = %{name: "some updated name", google_id: "some updated google_id", email: "some updated email", access_token: "some updated access_token", refresh_token: "some updated refresh_token", token_expires_at: ~U[2024-10-13 20:18:00Z]}

      assert {:ok, %Users{} = users} = Accounts.update_users(users, update_attrs)
      assert users.name == "some updated name"
      assert users.google_id == "some updated google_id"
      assert users.email == "some updated email"
      assert users.access_token == "some updated access_token"
      assert users.refresh_token == "some updated refresh_token"
      assert users.token_expires_at == ~U[2024-10-13 20:18:00Z]
    end

    test "update_users/2 with invalid data returns error changeset" do
      users = users_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_users(users, @invalid_attrs)
      assert users == Accounts.get_users!(users.id)
    end

    test "delete_users/1 deletes the users" do
      users = users_fixture()
      assert {:ok, %Users{}} = Accounts.delete_users(users)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_users!(users.id) end
    end

    test "change_users/1 returns a users changeset" do
      users = users_fixture()
      assert %Ecto.Changeset{} = Accounts.change_users(users)
    end
  end
end
