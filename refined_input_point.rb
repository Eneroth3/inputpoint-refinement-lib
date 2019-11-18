module RefinedInputPoint
  refine Sketchup::InputPoint do
    # Get constraint direction or normal. When InputPoint gets its position from
    # a point or free space there is no relevant constraint and nil is returned.
    #
    # Use `#degrees_of_freedom` to see if returned vector resembles a direction
    # or a normal.
    #
    # @return [Geom::Vector3d, nil]
    def freedom_constraint
      case degrees_of_freedom
      when 1
        # TODO: Support constraint to drawing axis.
        source_edge && edge.line[1].transform(transformation)
      when 2
        source_face && transform_as_normal(face.normal, transformation)
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

    def local_position
      position.transform(transformation.inverse)
    end

    # Return new vector transformed as a normal.
    #
    # @param normal [Geom::Vector3d]
    # @param transformation [Geom::Transformation]
    #
    # @return [Geom::Vector3d]
    def transform_as_normal(normal, transformation)
      normal.transform(transpose(transformation).inverse).normalize
    end

    # Transpose of 3X3 matrix (ignore translation).
    #
    # @param transformation [Geom::Transformation]
    #
    # @return [Geom::Transformation]
    def transpose(transformation)
      a = transformation.to_a

      Geom::Transformation.new([
        a[0], a[4], a[8],  0,
        a[1], a[5], a[9],  0,
        a[2], a[6], a[10], 0,
        0,    0,    0,     a[15]
      ])
    end
  end
end