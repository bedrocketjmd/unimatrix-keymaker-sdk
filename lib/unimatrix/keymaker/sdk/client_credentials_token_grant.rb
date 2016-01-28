module Unimatrix
  module Keymaker
    module Sdk
      class ClientCredentialsTokenGrant
        def initialize( args )
          @client_id = args[ :client_id ]
          @client_secret = args[ :client_secret ]
        end

        def request_token
          uri      = URI.parse( "#{ ENV[ 'KEYMAKER_URL' ] }/token" )
          params   = { "client_id"     => @client_id,
                       "client_secret" => @client_secret,
                       "grant_type"    => "client_credentials" }
          response = Net::HTTP.post_form( uri, params ) rescue nil

          if response
            JSON.parse( response.body )[ 'token' ][ 'access_token' ] rescue nil
          end
        end
      end
    end
  end
end

