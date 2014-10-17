require 'logger'
require 'net/https'
require 'rexml/document'
require 'cgi'
require 'uri'
require 'date'
include REXML

module OneLogin
  class API
    attr_accessor :api_key, :logger

    def initialize(api_key)
      @base_url = 'https://app.onelogin.com/api/v2/'
      @api_key = api_key
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
    end

    def api_request(options)
      @logger.debug "api request #{options}"
      http_request({  uri: @base_url + options[:service],
                      login: @api_key,
                      password: 'x',
                      get_params: {'include_custom_attributes' => 'true'} })
    end

    private

    def http_request(options, limit = 10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      @logger.debug "http request #{options}"

      uri = URI.parse(options[:uri])

      if ! options[:get_params].nil?
        get_params = options[:get_params].collect { |k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}" }.join('&')
        uri.query = uri.query.nil? ? get_params : uri.query + '&' + get_params
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = nil
      if options[:post_data].nil?
        request = Net::HTTP::Get.new uri.request_uri
      else
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(options[:post_data])
      end
      request.basic_auth options[:login], options[:password] if options[:login] && options[:password]

      response = http.request(request)

      case response
      when Net::HTTPSuccess then return response.body
      when Net::HTTPRedirection then http_request(options, limit - 1)
      else
        response.error!
      end
    end
  end

end
