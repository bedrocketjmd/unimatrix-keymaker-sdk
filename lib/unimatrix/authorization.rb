require 'unimatrix/authorization/version'

require 'unimatrix/authorization/filters/requires_policies'
require 'unimatrix/authorization/client_credentials_grant'
require 'unimatrix/authorization/railtie' if defined?( Rails )