defprotocol Tableau.Graph.Nodable do
  @moduledoc false
  def template(nodable, assigns)
  def type(nodable)
  def parent(nodable)
  def permalink(nodable)
  def opts(nodable)
end

defimpl Tableau.Graph.Nodable, for: Atom do
  def template(nodable, assigns), do: nodable.template(assigns)
  def type(nodable), do: Tableau.Graph.Node.type(nodable)
  def parent(nodable), do: Tableau.Graph.Node.parent(nodable)
  def opts(nodable), do: nodable.__tableau_opts__()
  def permalink(nodable), do: nodable.__tableau_permalink__()
end
