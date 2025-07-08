ExUnit.start()
Mox.defmock(F1Dashboard.External.MockClient, for: F1Dashboard.External.Client)
Application.put_env(:f1_dashboard, :api, F1Dashboard.External.MockClient)
