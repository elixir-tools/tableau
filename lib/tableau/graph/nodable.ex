defprotocol Tableau.Graph.Nodable do
  @moduledoc false
  def template(nodable, assigns)
  def type(nodable)
  def permalink(nodable)
  def opts(nodable)
end

defimpl Tableau.Graph.Nodable, for: Map do
  def template(nodable, _assigns), do: nodable.template
  def type(nodable), do: {:ok, nodable.type}
  def opts(nodable), do: nodable.opts
  def permalink(nodable), do: nodable.permalink
end

defimpl Tableau.Graph.Nodable, for: Atom do
  def template(nodable, assigns), do: nodable.template(assigns)
  def type(nodable), do: Tableau.Graph.Node.type(nodable)
  def opts(nodable), do: nodable.__tableau_opts__()
  def permalink(nodable), do: nodable.__tableau_permalink__()
end
