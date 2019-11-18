class FreedomConstraintTestTool
  using RefinedInputPoint

  # Radius in pixels.
  RADIUS = 50

  def initialize
    @ip = Sketchup::InputPoint.new
  end

  def draw(view)
    @ip.draw(view)
    return unless @ip.freedom_constraint

    view.line_width = 5
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
  # @param line [Array<(Geom::Point3d, Geom::Vector3d)>]
  # @param view [Sketchup::View]
  def draw_line_constraint(line, view)
    color_from_line(line, view)
    offset = view.pixels_to_model(RADIUS, @ip.position)
    points = [
      @ip.position.offset(line[1], offset),
      @ip.position.offset(line[1], -offset)
    ]
    view.draw(GL_LINES, points)
  end

  # Draw plane constraint.
  #
  # @param plane [Array<(Geom::Point3d, Geom::Vector3d)>]
  # @param view [Sketchup::View]
  def draw_plane_constraint(line, view)
    color_from_line(line, view)
    radius = view.pixels_to_model(RADIUS, @ip.position)
    view.draw(GL_LINE_LOOP, circle(@ip.position, line[1], radius))
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

  def color_from_line(line, view)
    view.set_color_from_line(ORIGIN, ORIGIN.offset(line[1]))
  end
end

Sketchup.active_model.select_tool(FreedomConstraintTestTool.new)
