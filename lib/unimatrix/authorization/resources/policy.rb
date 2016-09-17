module Unimatrix::Authorization

  class Policy < Base
    field     :id
    field     :created_at
    field     :updated_at

    field     :resource
    field     :realm_uuid
    field     :actions

    has_one   :resources
    has_one   :resource_servers
  end

end
