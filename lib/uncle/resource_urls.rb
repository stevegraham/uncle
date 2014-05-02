module Uncle
  module ResourceUrls
    def parent_resource
      { uncle_request.parent_resource_name => uncle_request.parent_resource_url }
    end

    def child_resources
      Hash[uncle_request.child_resource_names.zip(uncle_request.child_resource_urls)]
    end

    private

    def uncle_request
      @uncle_request ||= Uncle::Request.new(request, self)
    end
  end
end
