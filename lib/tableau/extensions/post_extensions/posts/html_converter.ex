defmodule Tableau.PostExtension.Posts.HTMLConverter do
  @moduledoc false
  def convert(_filepath, body, _attrs, _opts) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    body |> MDEx.to_html(config.markdown[:mdex])
  end
end
