require 'net/https'
require 'addressable/uri'

module Unimatrix::Authorization

  class Request

    def initialize( default_parameters = {} )
      uri = URI.parse( URI.encode(Unimatrix::Authorization.configuration.url) )

      @http = Net::HTTP.new( uri.host, uri.port )
      @http.use_ssl = ( uri.scheme == 'https' )
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      @default_parameters = default_parameters.stringify_keys
    end

    def destroy( path, parameters = {} )
      begin
        request = Net::HTTP::Delete.new(
          compose_request_path( path, parameters ),
          { 'Content-Type' =>'application/json' }
        )

        response = Response.new( @http.request( request ) )
      rescue Timeout::Error
        response = nil
      end

      response
    end

    def get( path, parameters = {} )
      response = nil

      begin
        response = Response.new(
          @http.get( compose_request_path( path, parameters ) )
        )
      rescue Timeout::Error
        response = nil
      end

      response
    end

    def post( path, parameters={}, body={} )
      response = nil

      begin
        request = Net::HTTP::Post.new(
          compose_request_path( path, parameters ),
          { 'Content-Type' =>'application/json' }
        )
        request.body = body.to_json
        response = Response.new( @http.request( request ) )
      rescue Timeout::Error
        response = nil
      end

      response
    end

    protected; def compose_request_path( path, parameters = {} )
      parameters = @default_parameters.merge( parameters.stringify_keys )
      addressable = Addressable::URI.new
      addressable.path = path
      addressable.query = parameters.to_param unless parameters.blank?

      addressable.to_s
    end

  end

end
