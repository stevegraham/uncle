module Uncle
  module Resource
    def parent_resource(path_only=true)
      href = path_only ? uncle_request.parent_resource_path : uncle_request.parent_resource_url

      { uncle_request.parent_resource_name => href }
    end

    def child_resources(path_only=true)
      hrefs = path_only ? uncle_request.child_resource_paths : uncle_request.child_resource_urls
      links = Hash[uncle_request.child_resource_names.zip(hrefs)]

      if block_given?
        links.select &proc
      else
        links
      end
    end

    private

    def uncle_request
      @uncle_request ||= Uncle::Request.new(request)
    end
  end
end
