module Unimatrix
  module Authorization
    class RequiresPolicies

      def initialize( resource )
        @resource_name = resource
      end

      def policies
        @policies ||= retrieve_policies( @resource_name, @access_token, @realm_uuid )
      end

      def before( controller )
        @policies = nil
        @access_token = controller.params[ 'access_token' ]
        @realm_uuid = controller.realm_uuid || controller.realm.uuid

        if @access_token.present?

          if policies
            controller.policies = policies
            
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

    def policies=(attributes)
      @policies = attributes
    end

    def policies
      @policies ||= begin
        retrieve_policies( controller_name, params[:access_token], realm_uuid )
      end
    end

    private; def retrieve_policies( resource_name, access_token, realm )
      if resource_name && access_token && realm
        resource = "realm/#{ realm }::#{ ENV['APPLICATION_NAME'] }::#{ resource_name }/*"
        params   = "resource=#{ resource }&access_token=#{ access_token }"
        uri      = URI.parse( "#{ ENV['KEYMAKER_URL'] }/policies?#{ params }" )
        response = Net::HTTP.get( uri )
        JSON.parse( response )[ 'policies' ] rescue nil
      end
    end
    
  end
end