module Rack
  module SeoRedirect
    class TrailingSlash < Base
      def initialize app, slash = false, no_query_slash = false
        super(app)
        @should_ends_with_slash = slash
        @query_should_empty_slash = no_query_slash
      end

      def call env
        @env = env
        req = Rack::Request.new(env)
        ends_with_slash = /\A(.*)\/\z/.match(req.path)
        ends_query_with_slash = /\A(.*)%2F\z/.match(req.query_string)

        if req.get? && req.path != '/' && path_or_query_slash?(!ends_with_slash.nil?, !ends_query_with_slash.nil?)
          path = @should_ends_with_slash ? "#{req.path}/" : without_slash(ends_with_slash, req.path)
          query_string = @query_should_empty_slash ? without_slash(ends_query_with_slash, req.query_string) : req.query_string

          url = build_url(:path => path, :query_string => query_string)

          [ 301, headers(url), [ redirect_message(url) ] ]
        else
          @app.call(env)
        end
      end
    
      private

      def without_slash(match, data)
        return data if match.nil?
        match.captures[0]
      end

      def path_or_query_slash?(ends_with_slash, ends_query_with_slash)
        path_slash?(ends_with_slash) || query_slash?(ends_query_with_slash)
      end

      def path_slash?(ends_with_slash)
        @should_ends_with_slash != ends_with_slash
      end

      def query_slash?(ends_with_slash)
        @query_should_empty_slash && ends_with_slash
      end
    end
  end
end
