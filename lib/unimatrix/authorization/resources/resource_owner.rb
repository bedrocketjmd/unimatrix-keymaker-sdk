module Unimatrix::Authorization

  class ResourceOwner < Base
    field     :id
    field     :uuid
    field     :created_at
    field     :updated_at
    field     :destroyed_at
    field     :restricted_at

    field     :name
    field     :name_first
    field     :name_last
    field     :email_address
    field     :redirect_uri
    field     :properties

    has_many  :policies
  end

end
