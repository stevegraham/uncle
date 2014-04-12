class GizmosController < ApplicationController
  def index
    render json: parent_resource
  end
end
