module Unimatrix::Authorization

  class Policy < Base
    field     :id
    field     :created_at
    field     :updated_at

    field     :realm_uuid
    field     :resource_owner_id
    field     :resource_server_id
    field     :resource_id
    field     :actions

    has_one   :resource_owner
    has_one   :resource_server
    has_one   :resource

    field     :to_s
  end

end
