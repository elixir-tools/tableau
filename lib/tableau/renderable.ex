defprotocol Tableau.Renderable do
  def render(renderable)
  def render(renderable, opts)
  def refresh(renderable)
  def layout?(renderable)

  def write!(renderable, content)
end
