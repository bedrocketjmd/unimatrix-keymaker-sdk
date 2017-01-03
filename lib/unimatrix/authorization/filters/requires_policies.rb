module Unimatrix
  module Authorization
    class RequiresPolicies

      def initialize( resource )
        @resource_name = resource
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

        if access_token.present?
          policies = controller.retrieve_policies( @resource_name, access_token, realm_uuid )

          if policies.present? && policies.is_a?( Array )
            controller.policies = policies
            forbidden = true
            policies.each do | policy |
              if policy.actions.include?( controller.action_name )
                forbidden = false
              end
            end

            if forbidden
              controller.render_error(
                ForbiddenError,
                "A policy permitting this action was not found."
              )
            end
          else
            controller.render_error(
              ForbiddenError,
              "The requested policies could not be retrieved."
            )
          end
        else
          controller.render_error( 
            MissingParameterError,
            "The parameter 'access_token' is required."
          ) 
        end
      end
    end

    module ClassMethods

      def requires_policies( resource, options = {} )
        before_action(
          RequiresPolicies.new( resource ),
          options
        )
      end

    end

    def self.included( controller )
      controller.extend( ClassMethods )
    end

    def policies=( attributes )
      @policies = attributes
    end

    def policies
      @policies ||= begin
        # Used by Archivist requires_permission filter. Todo: deprecate
        retrieve_policies( @resource_name, params[ :access_token ], realm_uuid )
      end
    end

    # In Rails app, this is overwritten by #retrieve_policies in railtie.rb
    def retrieve_policies( resource_name, access_token, realm_uuid )
      if resource_name && access_token
        request_policies( resource_name, access_token, realm_uuid )
      end
    end

    def request_policies( resource_name, access_token, realm_uuid )
      if resource_name && access_token
        realm_uuid = realm_uuid || '*'

        Unimatrix::Authorization::Operation.new( '/policies' ).where( {
          access_token: access_token,
          resource: "realm/#{ realm_uuid }::#{ ENV['APPLICATION_NAME'] }::#{ resource_name }/*"
        } ).query
      end
    end
    
  end
end
