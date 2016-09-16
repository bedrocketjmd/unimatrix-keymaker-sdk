module Unimatrix::Authorization

  class Serializer

    def initialize( payload = [], options = {} )
      @payload = [ payload ].flatten
      @options = options
    end

    def serialize( node, options = {} )
      result = {}
      result[ node ] = @payload.map do | object |
        node_object = {}
        node_object[ :type_name ] = (
          object.respond_to?( :type_name ) ?
            object.type_name :
            object.class.name.gsub( /Unimatrix::Authorization::/, '' ).underscore
        )

        if object.respond_to?( :fields )
          object.fields.each do | name, options |
            node_object[ name.to_sym ] = object.send( name )
          end
        end
        node_object
      end

      result
    end

  end

end
