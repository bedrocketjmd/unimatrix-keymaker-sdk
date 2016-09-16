module Unimatrix::Authorization

  class Parser

    def initialize( content = {} )
      @content = content
      yield self if block_given?
    end

    def name
      @content.include?( '$this' ) ?
        @content[ '$this' ][ 'name' ] :
        nil
    end

    def type_name
      @content.include?( '$this' ) ?
        @content[ '$this' ][ 'type_name' ] :
        nil
    end

    def type_name?( name )
      self.type_name == name.to_s
    end

    def key
      'id'
    end

    def keys
      @content.include?( '$this' ) ? @content[ '$this' ][ 'ids' ] : nil
    end

    def associations
      @content.include?( '$associations' ) ?
        @content[ '$associations' ] :
        nil
    end

    def resources
      result = nil
      unless self.name.blank?
        result = self.keys.map do | key |
          self.resource_by( name, key, { 'type_name' => self.type_name } )
        end
      end
      result
    end

    def resource_by( name, key, options = {} )
      @resources_index ||= Hash.new { | hash, key | hash[ key ] = {} }
      @resource_index_mutex ||= Hash.new { | hash, key | hash[ key ] = [] }

      @resources_index[ name ][ key ] ||= begin
        # Lock the resource index for this name/key combination
        # This prevents objects that are associated with
        # themselves from causing a stack overflow
        return nil if @resource_index_mutex[ name ].include?( key )
        @resource_index_mutex[ name ].push( key )

        result = nil
        resource_attributes = resource_attribute_index[ name ][ key ]
        if resource_attributes.present?
          type_name = resource_attributes[ 'type_name' ]
          klass = nil

          if type_name.present?
            klass = Unimatrix::Authorization.const_get( type_name.camelize ) rescue nil
          end

          if klass.nil?
            type_name = options[ 'type_name' ]
            if type_name.present?
              klass = Unimatrix::Authorization.const_get( type_name.camelize ) rescue nil
            end
          end

          if klass.present?
            result = klass.new(
              resource_attributes,
              self.resource_associations_by( name, key )
            )
          end
        end

        # unlock the resource index for this name/key combination
        @resource_index_mutex[ name ].delete( key )

        result
      end
    end

    def resource_associations_by( name, key )
      result = Hash.new { | hash, key | hash[ key ] = [] }
      associations = self.associations
      if associations && associations.include?( name )
        association = associations[ name ].detect do | association |
          association[ 'id' ] == key
        end
        if association.present?
          association.each do | key, value |
            unless key == 'id'
              type_name = value[ 'type_name' ]
              result[ key ] = ( value[ 'ids' ] || [] ).map do | associated_id |
                self.resource_by(
                  key,
                  associated_id,
                  { 'type_name' => type_name }
                )
              end
              result[ key ].compact!
            end
          end
        end
      end
      result
    end

    def resource_attribute_index
      @resource_attribute_index ||= begin
        index = Hash.new { | hash, key | hash[ key ] = {} }
        @content.each do | key, resources_attributes |
          unless key[0] == '$'
            resources_attributes.each do | resource_attributes |
              index[ key ][ resource_attributes[ 'id' ] ] = resource_attributes
            end
          end
        end
        index
      end
    end

  end

end
