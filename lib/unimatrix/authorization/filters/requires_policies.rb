module Unimatrix
  module Authorization
    class RequiresPolicies

      def initialize( resource )
        @resource = resource
      end

      def before( controller )
        access_token = controller.params[ 'access_token' ]
        realm = controller.realm.uuid
        if access_token.present?
          str      = "realm/#{ realm }::#{ ENV[ 'APPLICATION_NAME' ] }::#{ @resource }/*"
          params   = "resource=#{ str }&access_token=#{ access_token }"
          uri      = URI.parse( "#{ ENV[ 'KEYMAKER_URL' ] }/policies?#{ params }" )
          response = Net::HTTP.get( uri ) rescue nil

          if response
            policies = JSON.parse( response )[ 'policies' ] rescue nil
            forbidden = true

            ( policies || [] ).each do | policy |
              if policy[ 'actions' ].include?( controller.action_name )
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