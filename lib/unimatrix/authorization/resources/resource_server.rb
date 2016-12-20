module Unimatrix::Authorization

  class ResourceServer < Base
    field     :id
    field     :uuid
    field     :created_at
    field     :updated_at

    field     :name
    field     :code_name
    field     :actions
    field     :resource_server_id

    has_one   :resource_server
    has_many  :policies
  end

end
