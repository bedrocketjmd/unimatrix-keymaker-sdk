require 'active_support'
require 'active_support/all'
require 'fnv'

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


# Resources
require 'unimatrix/authorization/resources/base'
require 'unimatrix/authorization/resources/error'
require 'unimatrix/authorization/resources/policy'
require 'unimatrix/authorization/resources/resource_owner'
require 'unimatrix/authorization/resources/resource'
require 'unimatrix/authorization/resources/resource_server'
