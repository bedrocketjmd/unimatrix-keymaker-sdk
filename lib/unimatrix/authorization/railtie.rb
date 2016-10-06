module Unimatrix
  module Authorization

    class Railtie < Rails::Railtie
      initializer "unimatrix.authorization.configure_controller" do | app |
        ActiveSupport.on_load :action_controller do
          include Unimatrix::Authorization
        end
      end
    end

    def retrieve_policies( resource_name, access_token, realm )
      if resource_name && access_token && realm
        resource  = "realm/#{ realm }::#{ ENV['APPLICATION_NAME'] }::#{ resource_name }/*"
        params    = "resource=#{ resource }&access_token=#{ access_token }"
        Rails.cache.fetch( Digest::SHA1.hexdigest( params ), expires_in: 1.minute ) do
          request_policies( params )
        end
      end
    end

  end
end


