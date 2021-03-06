require IEx
defmodule PhoenixGuardian.User do
  use PhoenixGuardian.Web, :model

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string

    timestamps
  end

  @required_fields ~w(first_name last_name email password)
  @optional_fields ~w(encrypted_password)

  @derive {Poison.Encoder, only: [:id, :first_name, :last_name, :email]}

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:password, message: "Password does not match")
    |> unique_constraint(:email, message: "Email already taken")
    |> generate_encrypted_password
  end


  defp generate_encrypted_password(current_changeset) do
    case current_changeset do

      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset

      IEx.pry
    
    end
  end

  defimpl Poison.Encoder, for: Any do
    def encode(%{__struct__: _} = struct, options) do
      map = struct
            |> Map.from_struct
            |> sanitize_map
      Poison.Encoder.Map.encode(map, options)
    end

    defp sanitize_map(map) do
      Map.drop(map, [:__meta__, :__struct__])
    end
  end
end
