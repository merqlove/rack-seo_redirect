require 'rack/mime'

module Rack
  module SeoRedirect
    class Base
      def initialize app
        @app = app
      end

      private

      def request
        Rack::Request.new(@env)
      end

      def headers url
        {
          'Location' => url,
          'Content-Type' => ::Rack::Mime.mime_type(::File.extname(request.path), 'text/html')
        }
      end

      def redirect_message url
        "Redirecting to <a href='#{url}'>#{url}</a>"
      end

      def build_url options = {}
        options[:host] ||= request.host
        options[:path] ||= request.path
        options[:query_string] ||= request.query_string

        url = "#{request.scheme}://#{options[:host]}"

        if request.scheme == "https" && request.port != 443 ||
          request.scheme == "http" && request.port != 80
          url << ":#{request.port}"
        end

        url << "#{options[:path]}"
        url << "?#{options[:query_string]}" unless options[:query_string].empty?

        url
      end
    end
  end
end
