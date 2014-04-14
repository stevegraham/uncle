require 'test_helper'

class UncleTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Dummy::Application
  end

  test 'returning the parent resource from a collection resource' do
    get '/widgets/1/gizmos'

    parent_resource = { 'widget' => 'http://example.org/widgets/1' }

    assert_equal parent_resource, JSON.parse(last_response.body)
  end

  test 'returning the parent resource from a resource instance' do
    get '/thingies/1'

    parent_resource = { 'thingies' => 'http://example.org/thingies' }

    assert_equal parent_resource, JSON.parse(last_response.body)
  end

  test 'returning the child resources from a resource instance' do
    get '/widgets/1'

    child_resources = {
      'gizmos'   => 'http://example.org/widgets/1/gizmos',
      'doo_dads' => 'http://example.org/widgets/1/doo_dads'
    }

    assert_equal child_resources, JSON.parse(last_response.body)
  end

  test 'returning the child resources from the root path' do
    get '/'

    child_resources = {
      'widgets'  => 'http://example.org/widgets',
      'thingies' => 'http://example.org/thingies'
    }
    
    assert_equal child_resources, JSON.parse(last_response.body)
  end
end
