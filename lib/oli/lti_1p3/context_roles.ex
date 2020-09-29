defmodule Oli.Lti_1p3.ContextRoles do
  alias Oli.Lti_1p3.ContextRole
  alias Oli.Lti_1p3.Lti_1p3_User

  # Core context roles
  @context_administrator %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Administrator"
  }

  @context_content_developer %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#ContentDeveloper"
  }

  @context_instructor %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"
  }

  @context_learner %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"
  }

  @context_mentor %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"
  }

  # Non‑core context roles
  @context_manager %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Manager"
  }

  @context_member %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Member"
  }

  @context_officer %ContextRole{
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Officer"
  }

  def list_roles(), do: [
    @context_administrator,
    @context_content_developer,
    @context_instructor,
    @context_learner,
    @context_mentor,
    @context_manager,
    @context_member,
    @context_officer,
  ]

  @doc """
  Returns a role from a given atom if it is valid, otherwise returns nil
  """
  def get_role(:context_administrator), do: @context_administrator
  def get_role(:context_content_developer), do: @context_content_developer
  def get_role(:context_instructor), do: @context_instructor
  def get_role(:context_learner), do: @context_learner
  def get_role(:context_mentor), do: @context_mentor
  def get_role(:context_manager), do: @context_manager
  def get_role(:context_member), do: @context_member
  def get_role(:context_officer), do: @context_officer
  def get_role(_invalid), do: nil

  @doc """
  Returns a role from a given uri if it is valid, otherwise returns nil
  """
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Administrator"), do: @context_administrator
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#ContentDeveloper"), do: @context_content_developer
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"), do: @context_instructor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"), do: @context_learner
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"), do: @context_mentor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Manager"), do: @context_manager
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Member"), do: @context_member
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Officer"), do: @context_officer
  def get_role_by_uri(_invalid), do: nil

  # TODO: ADD TESTS

  @doc """
  Returns all valid roles from a list of uris
  """
  def gets_roles_by_uris(uris) do
    # create a list only containing valid roles
    uris
      |> Enum.map(&(get_role_by_uri(&1)))
      |> Enum.filter(&(&1 != nil))
  end

  @doc """
  Returns true if a list of rule uris has a given role
  """
  def has_role?(roles, role) when is_list(roles) do
    Enum.any?(roles, fn r -> r.uri == get_role(role).uri end)
  end

  @doc """
  Returns true if a user has a given role
  """
  def has_role?(user, context_id, role) when is_struct(user) do
    roles = Lti_1p3_User.get_context_roles(user, context_id)
    Enum.any?(roles, fn r -> r.uri == get_role(role).uri end)
  end

  @doc """
  Returns true if a user has any of the given roles
  """
  def has_roles?(user, context_id, roles, :any) when is_struct(user) and is_list(roles) do
    context_roles_map = get_context_roles_map(user, context_id)
    Enum.any?(roles, fn r -> context_roles_map[r.uri] == true end)
  end

  @doc """
  Returns true if a user has all of the given roles
  """
  def has_roles?(user, context_id, roles, :all) when is_struct(user) and is_list(roles) do
    context_roles_map = get_context_roles_map(user, context_id)
    Enum.all?(roles, fn r -> context_roles_map[r.uri] == true end)
  end

  # Returns a map with keys of all role uris with value true if the user has the role, false otherwise
  defp get_context_roles_map(user, context_id) do
    context_roles = Lti_1p3_User.get_context_roles(user, context_id)
    Enum.reduce(list_roles(), %{}, fn r, acc -> Map.put_new(acc, r.uri, Enum.any?(context_roles, &(&1.uri == r.uri))) end)
  end

end
