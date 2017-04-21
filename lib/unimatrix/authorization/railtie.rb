module Unimatrix
  module Authorization

    class Railtie < Rails::Railtie
      initializer "unimatrix.authorization.configure_controller" do | app |
        ActiveSupport.on_load :action_controller do
          include Unimatrix::Authorization
        end
      end
    end

    def retrieve_policies( resource_name, access_token, realm_uuid, resource_server )
      if resource_name && access_token
        key = params.respond_to?( 'to_unsafe_h' ) ? 
              params.to_unsafe_h.sort.to_s : 
              params.sort.to_s
              
        Rails.cache.fetch(
          Digest::SHA1.hexdigest( key ),
          expires_in: 1.minute
        ) do
          request_policies( resource_name, access_token, realm_uuid, resource_server )
        end
      end
    end

  end
end
