require 'net/http'

module Unimatrix
  module Authorization
    class ClientCredentialsGrant
      def initialize( args )
        @client_id = args[ :client_id ]
        @client_secret = args[ :client_secret ]
      end

      def request_token( options = nil )
        uri      = URI.parse( "#{ ENV[ 'KEYMAKER_URL' ] }/token" )
        params   = { "grant_type" => "client_credentials" }
        http     = Net::HTTP.new( uri.host, uri.port )
        request  = Net::HTTP::Post.new( uri.request_uri )

        http.use_ssl = true if uri.scheme == 'https'

        request.basic_auth( @client_id, @client_secret )
        request.set_form_data( params )

        begin
          response = http.request( request )

          if response.code == '200'
            body = JSON.parse( response.body )
            body = body[ 'token' ] if body[ 'token' ].present?
            result = body[ 'access_token' ] rescue nil
            if options == 'include_expiry' 
              body.delete('token_type') if body[ 'token_type' ].present?
              result = body
            end
          else
            puts "ERROR: #{ response.body }"
          end
        rescue => e
          puts "REQUEST FAILED: #{ e }"
        end
        return result rescue nil
      end
    end
  end
end
