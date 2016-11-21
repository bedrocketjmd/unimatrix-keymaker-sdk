module Unimatrix
  module Authorization

    class Railtie < Rails::Railtie
      initializer "unimatrix.authorization.configure_controller" do | app |
        ActiveSupport.on_load :action_controller do
          include Unimatrix::Authorization
        end
      end
    end

    def retrieve_policies( resource_name, access_token, realm_uuid )
      if resource_name && access_token
        Rails.cache.fetch(
          Digest::SHA1.hexdigest( params.sort.to_s ),
          expires_in: 1.minute
        ) do
          request_policies( resource_name, access_token, realm_uuid )
        end
      end
    end

  end
end


