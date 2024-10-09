defmodule Tableau.PageExtension.Pages.HTMLConverter do
  @moduledoc false
  def convert(_filepath, body, _attrs, _opts) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    MDEx.to_html!(body, config.markdown[:mdex])
  end
end
