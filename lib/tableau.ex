defmodule Tableau do
  @moduledoc false
  defdelegate live_reload(assigns), to: WebDevUtils.Components

  def markdown(content, overrides \\ []) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    MDEx.to_html(content, Keyword.merge(config.markdown[:mdex], overrides))
  end
end
