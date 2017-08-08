module Unimatrix::Authorization

  class Parser

    def initialize( content, request_path )
      @request_path = request_path
      @content = content
      yield self if block_given?
    end

    def name
      @request_path[ 1..@request_path.length ]
    end

    def type_name
      self.name.present? ? name.singularize : nil
    end

    def resources
      result = nil
      unless self.name.blank?
        if @content.respond_to?( :keys )
          unless @content[ name ].is_a?( Array )
            # Handle singular object response ( e.g. resource_owner or error )
            result = parse_resource( self.name, @content )
          else
            # Handle object with node and array ( e.g. { policies: [ {} ] } )
            result = @content[ name ].map do | attributes |
              parse_resource( self.name, attributes )
            end
          end
        else
          # Handle json array response e.g. [ {}, {} ]
          result = @content.map do | attributes |
            self.parse_resource( self.name, attributes )
          end
        end
      end
      result
    end

    def parse_resource( name, attributes )
      resource = nil
      if attributes.present?
        class_name = name.singularize.camelize
        object_class = Unimatrix::Authorization.const_get( class_name ) rescue nil

        if object_class.present?
          resource = object_class.new( attributes )
        end
      end
      resource
    end

  end

end
