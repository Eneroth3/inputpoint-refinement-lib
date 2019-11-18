module RefinedInputPoint
  refine Sketchup::InputPoint do
    # Get constraint axis or plane. When InputPoint gets its position from a
    # a point or free space there is relevant constraint and nil is returned.
    #
    # @return [Array<(Geom::Point3d, Geom::Vector3d)>, nil]
    def freedom_constraint
      case degrees_of_freedom
      when 1
        return unless source_edge
        source_edge.line.map { |c| c.transform(transformation) }
      when 2
        return unless source_face
        format_plane(source_face.plane).map { |c| c.transform(transformation) }
      end
    end

    # Edge the InputPoint is getting its position from.
    #
    # It is unknown to me if native #edge is always the edge InputPoint is on,
    # or can also be in the background.
    #
    # @return [Sketchup::Edge, nil]
    def source_edge
      return unless edge
      return unless local_position.on_line?(edge.line)

      edge
    end

    # Face the InputPoint is getting its position from.
    #
    # Native #face doesn't necessarily return a face the InputPoint is getting
    # its position from, but can also be a face behind an InputPoint located
    # on a free standing edge or axis.
    #
    # @return [Sketchup::Edge, nil]
    def source_face
      return unless face
      return unless local_position.on_plane?(face.plane)

      face
    end

    private

    def format_plane(plane)
      return plane if plane.size == 2

      a, b, c, d = plane
      v = Geom::Vector3d.new(a, b, c)
      p = ORIGIN.offset(v.reverse, d)

      [p, v]
    end

    def local_position
      position.transform(transformation.inverse)
    end
  end
end
