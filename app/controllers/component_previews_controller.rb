class ComponentPreviewsController < ApplicationController
  def index
    @repositories = Repository.includes(:owner, :issues).limit(6)
  end
end
