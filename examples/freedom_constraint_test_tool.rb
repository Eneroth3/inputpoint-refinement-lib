require_relative("../lib/refined_input_point")

# Example/test tool for InputPoint#freedom_constraint.
#
# Draws a line communicating axial constraint or circle communicating planar
# constraint.
class FreedomConstraintTestTool
  using RefinedInputPoint

  # Radius in logical pixels.
  RADIUS = 50

  # Line width in logical pixels.
  LINE_WIDTH = 5

  def initialize
    @ip = Sketchup::InputPoint.new
  end

  def draw(view)
    @ip.draw(view)
    view.tooltip = @ip.tooltip

    return unless @ip.freedom_constraint

    view.line_width = LINE_WIDTH
    case @ip.degrees_of_freedom
    when 1
      draw_line_constraint(@ip.freedom_constraint, view)
    when 2
      draw_plane_constraint(@ip.freedom_constraint, view)
    end
  end

  def onMouseMove(_flags, x, y, view)
    @ip.pick(view, x, y)
    view.invalidate
    Sketchup.status_text = "#{@ip.degrees_of_freedom} degrees of freedom."
  end

  private

  # Draw line constraint.
  #
  # @param direction [Geom::Vector3d]
  # @param view [Sketchup::View]
  def draw_line_constraint(direction, view)
    set_color_from_vector(direction, view)
    offset = view.pixels_to_model(RADIUS, @ip.position)
    points = [
      @ip.position.offset(direction, offset),
      @ip.position.offset(direction, -offset)
    ]
    view.draw(GL_LINES, points)
  end

  # Draw plane constraint.
  #
  # @param normal [Geom::Vector3d]
  # @param view [Sketchup::View]
  def draw_plane_constraint(normal, view)
    set_color_from_vector(normal, view)
    radius = view.pixels_to_model(RADIUS, @ip.position)
    view.draw(GL_LINE_LOOP, circle(@ip.position, normal, radius))
  end

  def circle(center, normal, radius, segments = 32)
    points = Array.new(segments) do |i|
      angle = 2 * Math::PI / segments * i
      Geom::Point3d.new(Math.cos(angle), Math.sin(angle), 0)
    end
    transform = Geom::Transformation.new(center, normal) *
      Geom::Transformation.scaling(radius)

    points.map { |pt| pt.transform(transform) }
  end

  def set_color_from_vector(vector, view)
    view.set_color_from_line(ORIGIN, ORIGIN.offset(vector))
  end
end

Sketchup.active_model.select_tool(FreedomConstraintTestTool.new)
