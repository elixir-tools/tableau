defmodule Tableau.Components do
  @moduledoc """
  Builtin components.
  """
  require EEx

  import Tableau.Strung

  @doc """
  A component for triggering live reloading.

  Include this in your root layout to have your site live reload when using `mix tableau.server`.
  """
  EEx.function_from_string(
    :def,
    :live_reload,
    ~g'''
    <% {:ok, config} = Tableau.Config.new(Application.get_env(:tableau, :config, %{}) |> Map.new()) %>
    <script>
      function log(message) {
        if (<%= inspect(config.reload_log) %>) {
          console.log(`[tableau] ${message}`)
        }
      }
      function connect() {
        try {
          window.socket = new WebSocket('ws://' + location.host + '/ws');

          window.socket.onmessage = function(e) {
            if (e.data === "reload") {
              log("reloading!");
              location.reload();
            } else if (e.data === "subscribed") {
              log("connected and subscribed!");
            }
          }

          window.socket.onopen = () => {
            waitForConnection(() => {
              log("sending 'subscribe' message");
              window.socket.send("subscribe")
            }
            , 300);
          };

          window.socket.onclose = () => {
            setTimeout(() => connect(), 500);
          };

          function waitForConnection(callback, interval) {
            log("waiting for connection!")
            if (window.socket.readyState === 1) {
              callback();
            } else {
              log("setting a timeout")
              setTimeout(() => waitForConnection(callback, interval), interval);
            }
          }
        } catch (e) {
          log(e);
          setTimeout(() => connect(), 500);
        }
      }

      log("about to connect");
      connect();
    </script>
    '''html,
    [:_]
  )
end
