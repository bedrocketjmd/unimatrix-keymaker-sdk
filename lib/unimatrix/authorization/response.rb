module Unimatrix::Authorization

  class Response

    attr_reader :code
    attr_reader :body
    attr_reader :resources

    def initialize( http_response )
      @success = http_response.is_a?( Net::HTTPOK )
      @code = http_response.code
      @resources = []
      @body = decode_response_body( http_response )

      if ( @body && @body.respond_to?( :keys ) )
        Parser.new( @body ) do | parser |
          @resources = parser.resources
          @success = ( parser.type_name != 'error' )
        end
      else
        @success = false
        if @code != 200
          @resources << Error.new(
            message: "#{ @code }: #{ http_response.message }."
          )
        end
      end
    end

    def success?
      @success
    end

    protected; def decode_response_body( http_response )
      body = http_response.body

      if body.present?
        JSON.parse( body ) rescue nil
      else
        nil
      end
    end

  end

end
