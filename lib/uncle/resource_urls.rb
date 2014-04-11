module Uncle
  module ResourceUrls
    def parent_resource_path
      node = _routes.routes.match(request.path).detect do |node|
        node.value.one? do |route|
          (route.path.to_regexp === request.path) && route.matches?(request)
        end
      end

      key_path = node.parent.to_key_path

      key_path.map! { |segment| params[segment.tr(':', '')] || segment }
      key_path.join('/')
    end

    def parent_resource_url
      request.protocol + request.host_with_port + parent_resource_path
    end
  end
end
