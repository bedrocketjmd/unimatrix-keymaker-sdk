## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unimatrix-authorization'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unimatrix-authorization


## How to use
- The Keymaker SDK requires these environment variables:
```
KEYMAKER_URL=http://keymaker.boxxspring.com
KEYMAKER_CLIENT=
KEYMAKER_SECRET=
APPLICATION_NAME=  # E.g. dealer, gatekeeper, oracle
```

### Client Credential Grant
- Returns an access token based on the supplied Keymaker client ID and secret.

```ruby
  access_token = Unimatrix::Authorization::ClientCredentialsGrant.new(
    client_id: ENV[ 'KEYMAKER_CLIENT' ],
    client_secret: ENV[ 'KEYMAKER_SECRET' ]
  ).request_token
```

- The response is nil if an access token can't be found or created.

### Requires Policies Filter
- Used as a before_filter in controllers, it decides whether the access_token in the params has the permissions to perform certain actions in the controller.

- Example controller:
```ruby
module Realms
  class OffersController < ApplicationController

    requires_realm              # required
    requires_policies :offers

    def query
    end

  end
end
```

- When a request is made to Dealer's offers controller query action, the SDK will check for a policy in Keymaker where:
  + The policy's resource_owner_id matches the id of the resource owner associated with the access token.
  + The policy's resource's realm uuid matches the one in the request (`realm/*` means all realms are allowed).
  + The policy's actions include the action that the request is performing.
```
<Policy id: 3, resource_owner_id: 14, resource: "realm/*::dealer::transactions/*", actions: ["read", "query", "compute", "write"]>
```

