require 'spec_helper'

describe Rack::SeoRedirect::TrailingSlash do

  let(:base) { Proc.new { |env| [ 200, env, 'App' ] } }

  context "default behaviour" do
    let(:app) { Rack::SeoRedirect::TrailingSlash.new(base) }

    it 'set @should_ends_with_slash to false' do
      app.instance_variable_get('@opts').should == Rack::SeoRedirect::TrailingSlash::DEFAULT_OPTIONS
    end

    it 'removes trailing slash' do
      get 'http://www.example.com/users/'
      last_response.status.should == 301
      last_response.location.should == 'http://www.example.com/users'
    end
  end

  context "with trailing slash" do
    let(:app) { Rack::SeoRedirect::TrailingSlash.new(base,  path_without_slash: false, query_without_slash: false, exclude:[]) }

    it 'saves slash' do
      get 'http://example.com/users/'
      last_response.status.should == 200
    end

    it 'saves slash preserving port and path' do
      get 'http://example.com:3000/users/?foo=bar'
      last_response.status.should == 200
    end

    it 'does not do anything if slash is already in query' do
      get 'http://example.com/users/?foo=bar/'
      last_response.status.should == 200
    end

    it 'does not do anything for root url' do
      get 'http://example.com'
      last_response.status.should == 200

      get 'http://example.com/'
      last_response.status.should == 200
    end
  end

  context "with excluded paths" do
    let(:app) { Rack::SeoRedirect::TrailingSlash.new(base, path_without_slash: true, query_without_slash: false, exclude: [/\A^\/users/]) }

    it 'does not do anything if path excluded' do
      get 'http://example.com/users/?foo=bar'
      last_response.status.should == 200
    end
  end

  context "without trailing slash" do
    let(:app) { Rack::SeoRedirect::TrailingSlash.new(base, path_without_slash: true, query_without_slash: true, exclude:[]) }

    it 'removes slash' do
      get 'http://example.com/users/'
      last_response.status.should == 301
      last_response.location.should == 'http://example.com/users'
    end

    it 'removes slash from port and path' do
      get 'http://example.com:3000/users/?foo=bar'
      last_response.status.should == 301
      last_response.location.should == 'http://example.com:3000/users?foo=bar'
    end

    it 'remove slash after path and query' do
      get 'http://example.com:3000/users/?foo=bar/'
      last_response.status.should == 301
      last_response.location.should == 'http://example.com:3000/users?foo=bar'
    end

    it 'does not do anything if no slash in url' do
      get 'http://example.com/users?foo=bar'
      last_response.status.should == 200
    end

    it 'does not do anything for root url' do
      get 'http://example.com'
      last_response.status.should == 200

      get 'http://example.com/'
      last_response.status.should == 200
    end
  end
end
