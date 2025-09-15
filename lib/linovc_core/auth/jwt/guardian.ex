defmodule LinovcCore.Accounts.Guardian do
  alias LinovcCore.Auth.JWT.Permissions

  use Guardian,
    otp_app: :linovc_core,
    permissions: %{
      scopes: Permissions.valid_scopes()
    }

  use Guardian.Permissions, encoding: Guardian.Permissions.BitwiseEncoding

  def build_claims(claims, resource, opts) do
    token_type = Keyword.get(opts, :token_type, "access")

    exp =
      case token_type do
        # 3 minutes for access
        "access" -> System.system_time(:second) + 60 * 3
        # 24 hours for refresh
        "refresh" -> System.system_time(:second) + 60 * 60 * 24
        # default to 3 mins
        _ -> System.system_time(:second) + 60 * 3
      end

    permissions = %{scopes: resource.scopes}

    claims =
      claims
      |> Map.put("exp", exp)
      |> Map.put("typ", token_type)
      |> encode_permissions_into_claims!(permissions)

    {:ok, claims}
  end

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id, "typ" => "access"}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end

  def resource_from_claims(%{"typ" => _token_type}) do
    # reject refresh tokens or any other type for API 
    # requests that require auth pipeline
    {:error, :invalid_token_type}
  end
end
