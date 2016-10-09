module Unimatrix::Authorization

  class Parser

    def initialize( content = {} )
      @content = content
      yield self if block_given?
    end

    def name
      @content.keys.present? ? @content.keys.first : nil
    end

    def type_name
      self.name.present? ? name.singularize : nil
    end

    def key
      'id'
    end

    def resources
      result = nil

      unless self.name.blank?
        result = @content[ name ].map do | attributes |
          self.parse_resource( name, attributes )
        end
      end
      result
    end

    def parse_resource( name, attributes )
      @resources_mutex ||= Hash.new { | hash, key | hash[ key ] = [] }
      object_key = attributes[ key ]

      # Lock the resource index for this name/key combination
      # This prevents objects that are associated with
      # themselves from causing a stack overflow
      return nil if @resources_mutex[ name ].include?( object_key )

      @resources_mutex[ name ].push( object_key )
      resource = nil

      if attributes.present?
        class_name = name.singularize.camelize
        object_class = Unimatrix::Authorization.const_get( class_name ) rescue nil

        if object_class.present?
          relations = name == self.name ?
                        self.parse_associations( attributes ) : []
          resource = object_class.new( attributes, relations )
        end
        @resources_mutex[ name ].delete( object_key )
      end
      resource
    end

    def parse_associations( attributes )
      result = {}

      attributes.each do | attr_name, attr_value |
        if attr_value.class == Hash
          resource = self.parse_resource( attr_name, attr_value )
          result[ attr_name ] = result[ attr_name ] || []
          result[ attr_name ].push( resource )
          result[ attr_name ].compact!
        end
      end
      result
    end
  end

end
