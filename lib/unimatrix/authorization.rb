require 'unimatrix/authorization/version'

require 'unimatrix/authorization/filters/requires_policies'
require 'unimatrix/authorization/client_credentials_grant'
require 'unimatrix/authorization/railtie' if defined?( Rails )

# Operation
require 'unimatrix/authorization/configuration'
require 'unimatrix/authorization/response'
require 'unimatrix/authorization/request'
require 'unimatrix/authorization/parser'
require 'unimatrix/authorization/serializer'
require 'unimatrix/authorization/operation'
