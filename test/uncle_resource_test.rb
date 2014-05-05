require 'test_helper'

class UncleResourceTest < ActiveSupport::TestCase
  class Resource < Struct.new(:path)
    EXCLUDED_ACTIONS = %i<new edit>.freeze
    include Uncle::Resource

    def request
      ActionDispatch::TestRequest.new \
        Rack::MockRequest.env_for(path, method: 'GET')
    end

    def routeset
      ActionDispatch::Routing::RouteSet.new.tap do |set|
        set.draw do
          root 'widgets#show'

          resources :widgets, except: EXCLUDED_ACTIONS do
            resources :gizmos, except: EXCLUDED_ACTIONS
            resources :doo_dads, except: EXCLUDED_ACTIONS
          end

          resources :thingies, except: EXCLUDED_ACTIONS

          resource :user, except: EXCLUDED_ACTIONS do
            resource :profile, controller: 'thingies'
          end
        end
      end
    end

    def uncle_request
      Uncle::Request.new(request, routeset)
    end
  end

  def resource(path)
    Resource.new(path)
  end

  test 'parent_resource returns a hash of the parent resource name and path' do
    assert_equal \
      resource('/widgets/18/gizmos').parent_resource,
      { 'widget' => '/widgets/18' }
  end

  test 'parent_resource returns a hash of the parent resource name and url' do
    assert_equal \
      resource('/widgets/18/gizmos').parent_resource(false),
      { 'widget' => 'http://test.host/widgets/18' }
  end

  test 'child_resources returns a hash of the child resource names and urls' do
    assert_equal \
      resource('/widgets/18').child_resources(false),
      { 'gizmos'   => 'http://test.host/widgets/18/gizmos',
        'doo_dads' => 'http://test.host/widgets/18/doo_dads' }
  end

  test 'child_resources returns a hash of the child resource paths and urls' do
    assert_equal \
      resource('/widgets/18').child_resources,
      { 'gizmos'   => '/widgets/18/gizmos',
        'doo_dads' => '/widgets/18/doo_dads' }
  end

  test 'child resource paths takes a block that yields each paths params' do
    params = []
    r = resource('/')
    r.child_resources { |n, p| params << [n, p] }

    assert_equal params, r.child_resources.map { |n, p| [n, p] }
  end

  test 'child resource urls takes a block that returns resources where the block evaluates to true' do
    assert_equal resource('/').child_resources { |_,_| false }, {}
  end
end
