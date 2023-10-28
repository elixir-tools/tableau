defmodule Tableau do
  defdelegate live_reload(assigns), to: WebDevUtils.Components
end
