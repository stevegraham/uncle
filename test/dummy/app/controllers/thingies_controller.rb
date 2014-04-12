class ThingiesController < ApplicationController
  def show
    render json: parent_resource
  end
end
