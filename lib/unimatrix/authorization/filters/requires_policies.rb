module Unimatrix
  module Authorization
    class RequiresPolicies

      def initialize( resource )
        @resource_name = resource
      end

      def before( controller )
        @access_token = controller.params[ 'access_token' ]
        @realm_uuid = controller.realm.uuid

        if @access_token.present?
          response = keymaker_response

          if response
            policies = JSON.parse( response )[ 'policies' ] rescue []
            forbidden = true

            policies.each do | policy |
              controller_action_allowed = policy['actions'].detect do |action|
                controller.action_name.include?( action )
              end.present?

              if policy[ 'actions' ].include?( controller.action_name ) ||
                 controller_action_allowed
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
              NotFoundError,
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

      def keymaker_response
        resource = "realm/#{ @realm_uuid }::#{ ENV['APPLICATION_NAME'] }::#{ @resource_name }/*"
        params   = "resource=#{ resource }&access_token=#{ @access_token }"
        uri      = URI.parse( "#{ ENV['KEYMAKER_URL'] }/policies?#{ params }" )
        Net::HTTP.get( uri ) rescue nil
      end

    end

    module ClassMethods
      def requires_policies( resource, options = {} )
        before_filter(
          RequiresPolicies.new( resource ),
          options
        )
      end
    end

    def self.included( controller )
      controller.extend( ClassMethods )
    end
  end
end