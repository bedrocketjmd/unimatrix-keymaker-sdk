module Unimatrix
  module Authorization
    class Railtie < Rails::Railtie
      initializer "unimatrix.authorization.configure_controller" do | app |
        ActiveSupport.on_load :action_controller do
          include Unimatrix::Authorization
        end
      end
    end
  end
end