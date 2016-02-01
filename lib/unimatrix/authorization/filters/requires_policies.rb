module Unimatrix
  module Authorization
    class RequiresPolicies

      def initialize( application, resource )
        @application = application
        @resource = resource
      end

      def before( controller )
        access_token = controller.params[ 'access_token' ] ||
                       Rails.application.config.client_access_token
        realm = controller.realm.uuid
        if access_token.present?
          str      = "realm/#{ realm }::#{ @application }::#{ @resource }/*"
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
              ApplicationError,
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
      def requires_policies( application, resource )
        before_filter( RequiresPolicies.new( application, resource ) )
      end
    end

    def self.included( controller )
      controller.extend( ClassMethods )
    end
  end
end