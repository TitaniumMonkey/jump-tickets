import Config

if System.get_env("PHX_SERVER") do
  config :jump_tickets, JumpTicketsWeb.Endpoint, server: true
end

config :jump_tickets,
  intercom_token: System.get_env("INTERCOM_SECRET")

config :jump_tickets,
  claude_secret: System.get_env("CLAUDE_SECRET")

config :jump_tickets,
  slack_secret: System.get_env("SLACK_SECRET")

config :jump_tickets,
  notion_db_id: System.get_env("NOTION_DB_ID")

config :jump_tickets,
  :intercom,
  admin_id: System.get_env("INTERCOM_ADMIN_ID")

config :notionex,
  bearer_token: System.get_env("NOTION_SECRET")

config :jump_tickets,
  :slack,
  bot_token: System.get_env("SLACK_BOT_TOKEN")

if config_env() == :prod do
  _maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :jump_tickets, JumpTickets.Repo,
    database: "sqlite/prod.sqlite"

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4001")

  config :jump_tickets, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :jump_tickets, JumpTicketsWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    # Add check_origin to allow both local and ngrok origins
    check_origin: [
      "http://localhost:4001",            # For local testing
      "https://121b-73-140-243-93.ngrok-free.app"  # For ngrok access
    ],
    secret_key_base: secret_key_base
end
