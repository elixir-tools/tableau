defmodule Tableau.Components.LiveReload do
  import Temple.Component

  render do
    script defer: true do
      """
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
              setTimeout(() => waitForConnection(callback, interval), interval);
            }
          }
        } catch (e) {
          setTimeout(() => connect(), 500);
        }
      }

      connect();
      """
    end
  end
end
