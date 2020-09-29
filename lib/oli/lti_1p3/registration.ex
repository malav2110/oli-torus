defmodule Oli.Lti_1p3.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lti_1p3_registrations" do
    field :issuer, :string
    field :client_id, :string
    field :key_set_url, :string
    field :auth_token_url, :string
    field :auth_login_url, :string
    field :auth_server, :string
    field :kid, :string

    has_many :deployments, Oli.Lti_1p3.Deployment
    belongs_to :tool_jwk, Oli.Lti_1p3.Jwk, foreign_key: :tool_jwk_id
    belongs_to :institution, Oli.Accounts.Institution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(registration, attrs \\ %{}) do
    registration
    |> cast(attrs, [:issuer, :client_id, :key_set_url, :auth_token_url, :auth_login_url, :auth_server, :kid, :tool_jwk_id, :institution_id])
    |> validate_required([:issuer, :client_id, :key_set_url, :auth_token_url, :auth_login_url, :auth_server, :kid, :tool_jwk_id, :institution_id])
  end
end
