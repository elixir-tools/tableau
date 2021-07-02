defprotocol Tableau.Renderable do
  def render(renderable)
  def layout?(renderable)
end
