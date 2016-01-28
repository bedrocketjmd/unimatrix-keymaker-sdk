module Unimatrix
  module Keymaker
    module Sdk
      class TokenGrant
        def initialize( client_id, client_secret )
          @client_id = client_id
          @client_secret = client_secret
        end

        def request_token
        end
      end
    end
  end
end