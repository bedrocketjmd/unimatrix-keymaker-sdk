module Unimatrix::Authorization

  class Base

    class << self

      def inherited( subclass )
        subclass.fields = {}.merge( self.fields )
      end

      def field( name, options = {} )
        self.fields[ name.to_sym ] = options.merge( name: name )

        class_eval(
          "def #{ name }(); " +
          "@#{ name }.is_a?( FalseClass ) ? @#{ name } : (" +
             "@#{ name } || " +
               ( options[ :default ].nil? ?
                  "nil" :
                  ( options[ :default ].is_a?( String ) ?
                      "'#{ options[ :default ] }'" :
                        "#{ options[ :default ] }" ) ) + ");" +
          "end;" +
          " " +
          "attr_writer :#{ name };",
          __FILE__,
          __LINE__
        )

      end

      def has_one( name, options = {} )
        define_method name do
          associations = self.instance_variable_get( "@_#{ name.to_s.pluralize }" )
          associations.present? ? associations.first : options[ :default ]
        end
      end

      def has_many( name, options = {} )
        define_method name do 
          self.instance_variable_get( "@_#{ name }" ) ||
          options[ :default ] || []
        end
      end

    end

    class_attribute :fields, instance_writer: false
    self.fields = {}

    field :type_name
    has_many  :errors

    def initialize( attributes={}, associations={} )
      self.type_name = self.class.name.gsub( /Unimatrix::Authorization::/, '' ).underscore

      attributes.each do | key, value |
        send( "#{ key }=", value ) if respond_to?( "#{ key }=" )
      end

      associations.each do | key, value |
        self.instance_variable_set( "@_#{ key }", value )
      end

      yield self if block_given?
    end

  end

end
