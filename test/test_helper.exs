ExUnit.start

Mix.Task.run "ecto.create", ~w(-r PhoenixGuardian.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r PhoenixGuardian.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(PhoenixGuardian.Repo)

