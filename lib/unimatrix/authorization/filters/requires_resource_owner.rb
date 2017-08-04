module Unimatrix
  module Authorization

    module ClassMethods
      def requires_resource_owner( name, options = {} )
        before_action( RequiresResourceOwner.new( name, options ), options )
      end
    end

    class RequiresResourceOwner
      def initialize( resource, options={} )
      end

      def before( controller )
        access_token = controller.params[ 'access_token' ]

        resource_owner = controller.request_resource_owner(
          access_token
        )
      end
    end

    def self.included( controller )
      controller.extend( ClassMethods )
    end

    def request_resource_owner( access_token )
      user = Unimatrix::Authorization::Operation.new( '/resource_owner' ).
      where( {
        access_token: access_token
      } ).
      query
    end

    def resource_owner=( attributes )
      @resource_owner = attributes
    end

    def resource_owner
      @resource_owner ||= begin
        request_resource_owner(
          params[ :access_token ]
        )
      end
    end

  end
end
