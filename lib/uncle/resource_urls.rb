module Uncle
  module ResourceUrls
    def parent_resource
      { parent_resource_name => parent_resource_url }
    end

    def parent_resource_name
      _controller_name_for_path(parent_resource_path)
    end

    def parent_resource_url
      request.protocol + request.host_with_port + parent_resource_path
    end

    def parent_resource_path
      node     = _node_for_path(request.path)
      key_path = node.parent.to_key_path

      key_path.map! { |segment| params[segment.tr(':', '')] || segment }
      key_path.join('/')
    end

    def child_resources
      id_name = "#{controller_name.singularize}_id"
      params  = request.params.dup
      nodes   = _node_for_path(request.path).siblings
      nodes   = nodes.detect { |c| c.key == ":#{id_name}" }
      nodes   = nodes.children

      routes    = nodes.flat_map(&:value).select { |r| r.matches?(request) }
      key_paths = nodes.map(&:to_key_path)

      params[id_name] = params.delete('id') if params.has_key?('id')

      urls = key_paths.map! do |kp|
        kp.map! { |segment| params[segment.tr(':', '')] || segment }
        request.protocol + request.host_with_port + kp.join('/')
      end

      names = routes.map { |r| r.app.defaults[:controller] }

      Hash[names.zip(urls)]
    end

    private

    def _controller_name_for_path(path)
      route = _routes.routes.match(path).
        flat_map(&:value).
        detect { |r| r.path.to_regexp === path && r.matches?(request) }

      route.app.defaults[:controller]
    end

    def _node_for_path(path)
      _routes.routes.match(path).detect(&_node_elimination_block(path))
    end

    def _node_elimination_block(path)
      lambda do |node|
        node.value.one? do |r|
          r.path.to_regexp === path && r.matches?(request)
        end
      end
    end
  end
end
