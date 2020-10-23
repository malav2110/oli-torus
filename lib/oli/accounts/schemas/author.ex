defmodule Oli.Accounts.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias Oli.Accounts.SystemRole

  schema "authors" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :provider, :string
    field :token, :string
    # virtual fields are NOT persisted to the database
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :email_verified, :boolean, default: false
    embeds_one :preferences, Oli.Accounts.AuthorPreferences
    belongs_to :system_role, Oli.Accounts.SystemRole
    has_many :institutions, Oli.Institutions.Institution
    has_many :users, Oli.Accounts.User
    many_to_many :projects, Oli.Authoring.Course.Project, join_through: Oli.Authoring.Authors.AuthorProject, on_replace: :delete
    many_to_many :sections, Oli.Delivery.Sections.Section, join_through: Oli.Delivery.Sections.AuthorSection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs \\ %{}, opts \\ []) do
    ignore_required = case opts do
      [ ignore_required: ignore_required ] -> ignore_required
      _ -> nil
    end

    author
    |> cast(attrs, [
      :email,
      :first_name,
      :last_name,
      :provider,
      :token,
      :password,
      :email_verified,
      :system_role_id,
    ])
    |> cast_embed(:preferences)
    |> validate_required(
      [:email, :first_name, :last_name, :provider]
      |> filter_ignored_fields(ignore_required)
    )
    |> default_system_role()
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "does not match password")
    |> lowercase_email()
    |> hash_password()
  end

  defp filter_ignored_fields(fields, nil), do: fields
  defp filter_ignored_fields(fields, ignored_fields) do
    Enum.filter(fields, fn field ->
      if Enum.member?(ignored_fields, field), do: false, else: true
    end)
  end

  defp default_system_role(changeset) do
    case changeset do
      # if changeset is valid and doesnt have a system role set, default to author
      %Ecto.Changeset{valid?: true, changes: changes, data: %Oli.Accounts.Author{system_role_id: nil}} ->
        case Map.get(changes, :system_role_id) do
          nil ->
            put_change(changeset, :system_role_id, SystemRole.role_id.author)

          _ ->
            changeset
        end

      _ ->
        changeset
    end
  end

  defp hash_password(changeset) do
    case changeset do
      # if changeset is valid and has a password, we want to convert it to a hash
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  defp lowercase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end
end