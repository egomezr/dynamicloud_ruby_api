require 'rubygems'
require 'json'
require 'httpclient'

module DynamicService
  # Class to call services
  # @author Eleazar Gomez
  # @version 1.0.0
  # @since 8/22/15
  class ServiceCaller
    #@param service_url this the url to invoke
    #@param params optional params that will be attached to the request
    #@param method http method that will be used
    #@param headers these are optional headers that will be attached to this request
    #@param destiny this is a file that will be used to store a file from Dynamicloud servers
    def self.call_service(service_url, params = {}, method = 'post', headers = {}, destiny = nil)
      http = HTTPClient.new
      http.connect_timeout = 10

      headers['User-Agent'] = 'Dynamicloud client'
      headers['APIVersion'] = Configuration::PROPERTIES.get_property :version
      headers['Language'] = 'Ruby'

      # download file
      if destiny
        destiny.write(http.get_content(service_url))
        return
      end

      if method.eql? 'post'
        return handle_response(http.post service_url, params)
      end

      if method.eql? 'get'
        return handle_response(http.get service_url, params)
      end

      if method.eql? 'delete'
        return handle_response(http.delete service_url, params)
      else
        raise 'Unsupported Http Method - "' << method.to_s << '"'
      end
    end

    private
    #Validate the http response status
    def self.handle_response(response)
      begin
        if response.status == 200
          response.content
        else
          parsed_json = JSON.parse(response.content)
          message = parsed_json['message']

          if message
            raise message
          else
            raise 'Fatal error executing request'
          end
        end
      rescue StandardError => se
        raise se.message
      end
    end
  end
end