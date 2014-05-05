require 'test_helper'

class UncleRequestTest < ActiveSupport::TestCase
  EXCLUDED_ACTIONS = %i<new edit>.freeze

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

  def uncle(path)
    env     = Rack::MockRequest.env_for path, method: 'GET'
    request = ActionDispatch::TestRequest.new env

    Uncle::Request.new(request, routeset)
  end

  test 'inferring the parent resource name from a resource instance' do
    assert_equal uncle('/widgets/18').parent_resource_name, 'widgets'
  end

  test 'inferring the parent resource name from a collection resource' do
    assert_equal uncle('/widgets/18/gizmos').parent_resource_name, 'widget'
  end

  test 'inferring the parent resource path' do
    assert_equal uncle('/widgets/18').parent_resource_path, '/widgets'
  end

  test 'inferring the parent resource url' do
    assert_equal uncle('/widgets/18').parent_resource_url, 'http://test.host/widgets'
  end

  test 'parent resource name is singular when it is a singelton' do
    assert_equal uncle('/user/profile').parent_resource_name, 'user'
  end

  test 'inferring the child resource names from a resource instance' do
    assert_equal uncle('/widgets/1').child_resource_names, ['gizmos', 'doo_dads']
  end

  test 'inferring the child resource paths from a resource instance' do
    assert_equal \
      uncle('/widgets/1').child_resource_paths,
      ['/widgets/1/gizmos', '/widgets/1/doo_dads']
  end

  test 'inferring the child resource urls from a resource instance' do
    assert_equal \
      uncle('/widgets/1').child_resource_urls,
      ['http://test.host/widgets/1/gizmos', 'http://test.host/widgets/1/doo_dads']
  end

  test 'returning the child resource names from the root path' do
    assert_equal uncle('/').child_resource_names, ['widgets', 'thingies', 'user']
  end

  test 'returning the child resource paths from the root path' do
    assert_equal \
      uncle('/').child_resource_paths,
      ['/widgets', '/thingies', '/user']
  end

  test 'returning the child resource urls from the root path' do
    assert_equal \
      uncle('/').child_resource_urls,
      ['http://test.host/widgets', 'http://test.host/thingies', 'http://test.host/user']
  end

  test 'child resource paths takes a block that returns resources where the block evaluates to true' do
    assert_equal uncle('/').child_resource_paths { |p| false }, []
  end

  test 'child resource paths takes a block that yields each paths params' do
    params = []
    uncle('/').child_resource_paths { |p| params << p }

    assert_equal params, uncle('/').child_resource_paths.map { |p| routeset.recognize_path p }
  end

  test 'child resource urls takes a block that returns resources where the block evaluates to true' do
    assert_equal uncle('/').child_resource_urls { |p| false }, []
  end

  test 'child resource urlss takes a block that yields each paths params' do
    params = []
    uncle('/').child_resource_urls { |p| params << p }

    assert_equal params, uncle('/').child_resource_urls.map { |p| routeset.recognize_path p }
  end

  test 'child resource names takes a block that returns resources where the block evaluates to true' do
    assert_equal uncle('/').child_resource_names { |p| false }, []
  end

  test 'child resource names takes a block that yields each paths params' do
    params = []
    uncle('/').child_resource_names { |p| params << p }

    assert_equal params, uncle('/').child_resource_names.map { |p| routeset.recognize_path p }
  end
end
