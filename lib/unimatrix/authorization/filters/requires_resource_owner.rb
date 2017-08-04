module Unimatrix
  module Authorization

    module ClassMethods
      def requires_resource_owner( name, options = {} )
        before_action( RequiresResourceOwner.new( name, options ), options )
      end
    end

    class RequiresResourceOwner
      def initialize( resource, options={} )
        @resource_name = resource
        @resource_server = options[ :resource_server ] || ENV[ 'APPLICATION_NAME' ]
      end

      def before( controller )
        access_token = controller.params[ 'access_token' ]

        realm_uuid = begin
          if controller.respond_to? :realm_uuid
            controller.realm_uuid
          elsif controller.respond_to? :realm
            controller.realm.uuid
          else
            controller.params[ :realm_uuid ]
          end
        end
        resource_owner = controller.request_resource_owner(
          access_token,
          realm_uuid,
          @resource_server,
          @resource_name
        )
      end
    end

    def self.included( controller )
      controller.extend( ClassMethods )
    end

    def request_resource_owner( access_token, realm_uuid = '*', resource_server, resource_name )
      user = Unimatrix::Authorization::Operation.new( '/resource_owner' ).
      where( {
        access_token: access_token,
        resource: "realm/#{ realm_uuid }::#{ resource_server }::#{ resource_name }/*"
      } ).
      query
    end

    def resource_owner=( attributes )
      @resource_owner = attributes
    end

    def resource_owner
      @resource_owner ||= begin
        request_resource_owner(
          params[ :access_token ],
          params[ :realm_uuid ],
          @resource_server,
          @resource_name
        )
      end
    end

  end
end
