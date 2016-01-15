require "unimatrix/keymaker/sdk/version"

module Unimatrix
  module Keymaker
    module Sdk
      class RequiresPolicies

        def initialize( application, resource )
          @application = application
          @resource = resource
        end

        def before( controller )
          result = false
          access_token = controller.params[ 'access_token' ]
          realm = controller.realm.uuid
          if access_token.present?
            str      = "realm/#{ realm }::#{ @application }::#{ @resource }/*"
            params   = "resource=#{ str }&access_token=#{ access_token }"
            uri      = URI.parse( "#{ ENV[ 'KEYMAKER_URL' ] }/policies?#{ params }" )
            response = Net::HTTP.get( uri )
            binding.pry
            controller.policies = JSON.parse( response )[ 'policies' ] rescue nil if response
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

      def permitted?
        return false if policies.blank?

        policies.each do | policy |
          return true if policy[ 'actions' ].include?( action_name )
        end

        false
      end
    end
  end
end
