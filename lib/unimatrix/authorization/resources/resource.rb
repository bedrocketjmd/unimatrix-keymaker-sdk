module Unimatrix::Authorization

  class Resource < Base
    field     :id
    field     :created_at
    field     :updated_at

    field     :resource_server_id
    field     :name
    field     :code_name
    field     :actions

    has_one   :resource_server
  end

end
