class WidgetsController < ApplicationController
  def index
    head :ok
  end

  def show
    render json: child_resources
  end
end
