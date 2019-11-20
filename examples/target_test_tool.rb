require_relative("../lib/refined_input_point")

# Example/test tool for custom InputPoint "on" getters.
#
# Highlights what edge, face and instance InputPoint is getting its position
# from by selecting them.
class OnTestTool
  using RefinedInputPoint

  def initialize
    @ip = Sketchup::InputPoint.new
  end

  def draw(view)
    @ip.draw(view)
    view.tooltip = @ip.tooltip
  end

  def onMouseMove(_flags, x, y, view)
    @ip.pick(view, x, y)
    view.invalidate
    highlight_entities(@ip)
    Sketchup.status_text = "#{@ip.degrees_of_freedom} degrees of freedom."
  end

  private

  def highlight_entities(ip)
    selection = Sketchup.active_model.selection
    selection.clear
    # Native #face can return a face behind the InputPoint position while
    # custom source_face only returns a face the point is actually on.
    # What the situation for native #edge is is unknown to me.
    selection.add(ip.source_face) if ip.source_face
    selection.add(ip.source_edge) if ip.source_edge
    selection.add(ip.instance) if ip.instance
  end
end

Sketchup.active_model.select_tool(OnTestTool.new)
