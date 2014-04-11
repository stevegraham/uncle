require 'test_helper'

class UncleIntegrationTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Dummy::Application
  end

  test 'returning the url of the parent resource' do
    get '/widgets/1/gizmos'

    assert_equal 'http://example.org/widgets/1', last_response.body
  end

  test 'returning the urls of children resources from a collection resource' do
    get '/widgets'

    skip
  end

  test 'returning the urls of children resources from a resource instance' do
    get '/widgets/1'

    skip
  end
end
