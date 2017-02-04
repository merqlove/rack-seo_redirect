module Rack
  module SeoRedirect
    class TrailingSlash < Base
      PATH_REGEX = /\A(.*)\/\z/
      QUERY_REGEX = /\A(.*)(\/|%2F)\z/
      DEFAULT_OPTIONS = {
        path_with_slash: false,
        query_without_slash: false,
        exclude: []
      }

      def initialize(app, opts = {})
        super(app)
        @opts = opts.each_with_object(DEFAULT_OPTIONS) do |(key, value), o|
          o[key] = value
        end
      end

      def call env
        @env = env
        req = Rack::Request.new(env)
        ends_with_slash = PATH_REGEX.match(req.path)
        ends_query_with_slash = QUERY_REGEX.match(req.query_string)

        if req.get? && req.path != '/' && path_or_query_slash?(!ends_with_slash.nil?, !ends_query_with_slash.nil?) && not_excluded_path?(req)
          path = @opts[:path_with_slash] ? "#{req.path}/" : without_slash(ends_with_slash, req.path)
          query_string = @opts[:query_without_slash] ? without_slash(ends_query_with_slash, req.query_string) : req.query_string

          url = build_url(:path => path, :query_string => query_string)

          [ 301, headers(url), [ redirect_message(url) ] ]
        else
          @app.call(env)
        end
      end
    
      private

      def not_excluded_path?(req) 
        @opts[:exclude].any? { |path| path.match(req.path) if path.is_a?(Regexp) } == false
      end
        
      def without_slash(match, data)
        return data if match.nil?
        match.captures[0]
      end

      def path_or_query_slash?(ends_with_slash, ends_query_with_slash)
        path_slash?(ends_with_slash) || query_slash?(ends_query_with_slash)
      end

      def path_slash?(ends_with_slash)
        @opts[:path_with_slash] != ends_with_slash
      end

      def query_slash?(ends_with_slash)
        @opts[:query_without_slash] && ends_with_slash
      end
    end
  end
end
