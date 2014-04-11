class GizmosController < ApplicationController
  def index
    render text: parent_resource_url
  end
end
