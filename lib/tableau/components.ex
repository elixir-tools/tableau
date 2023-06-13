defmodule Tableau.Components do
  require EEx

  import Tableau.Strung

  EEx.function_from_string(
    :def,
    :live_reload,
    ~g'''
    <script defer>
      function connect() {
        try {
          window.socket = new WebSocket('ws://' + location.host + '/ws');

          window.socket.onmessage = function(e) {
            if (e.data === "reload") {
              location.reload();
            }
          }

          window.socket.onopen = () => {
            waitForConnection(() => window.socket.send("subscribe"), 300);
          };

          window.socket.onclose = () => {
            setTimeout(() => connect(), 500);
          };

          function waitForConnection(callback, interval) {
            console.log("Waiting for connection!")
            if (window.socket.readyState === 1) {
              callback();
            } else {
              console.log("setting a timeout")
              setTimeout(() => waitForConnection(callback, interval), interval);
            }
          }
        } catch (e) {
          setTimeout(() => connect(), 500);
        }
      }

      connect();
    </script>
    '''html,
    [:_]
  )
end
