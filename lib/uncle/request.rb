module Uncle
  class Request < Struct.new(:request)
    def parent_resource_name
      node = node_for_path(parent_resource_path)
      name = controller_name_for_path(parent_resource_path)
      blk  = ->(n) { n.key =~ /[._]?id\Z/ }

      if blk[node] || node.children.none?(&blk)
        name.singularize
      else
        name
      end
    end

    def parent_resource_url
      request.protocol + request.host_with_port + parent_resource_path
    end

    def parent_resource_path
      @parent_resource_path ||= begin
         node     = node_for_path(request.path)
         key_path = node.parent.to_key_path

         key_path.map! { |segment| request.params[segment.tr(':', '')] || segment }
         key_path.join('/')
       end
    end

    def child_resource_names
      child_resource_nodes.reduce([]) do |memo, node|
        routes = node.value.select { |route| route.matches?(request) }

        routes.map! do |route|
          if node.children.any? { |n| n.key =~ /[._]?id\Z/ }
            route.app.defaults[:controller]
          else
            route.app.defaults[:controller].singularize
          end
        end

        memo.push(*routes)
      end
    end

    def child_resource_urls
      params    = request.params.dup
      key_paths = child_resource_nodes.map(&:to_key_path)

      params["#{resource_name}_id"] = params.delete('id') if params.has_key?('id')

      key_paths.map! do |kp|
        kp.map! { |segment| params[segment.tr(':', '')] || segment }
        request.protocol + request.host_with_port + kp.join('/')
      end
    end

    private

    def child_resource_nodes
      @child_resource_nodes ||= begin
        node = node_for_path(request.path)

        if node.parent
          nodes = node.parent.children
          node  = nodes.detect { |c| c.key == ":#{resource_name}_id" }
        end

        node.children
      end
    end

    def resource_name
      routeset.recognize_path(request.path)[:controller].singularize
    end

    def routeset
      Rails.application.routes
    end

    def controller_name_for_path(path)
      route = routeset.routes.match(path).
        flat_map(&:value).
        detect { |r| r.path.to_regexp === path && r.matches?(request) }

      route.app.defaults[:controller]
    end

    def node_for_path(path)
      routeset.routes.match(path).detect(&node_elimination_block(path))
    end

    def node_elimination_block(path)
      lambda do |node|
        node.value.any? do |r|
          r.path.to_regexp === path && r.matches?(request)
        end
      end
    end
  end
end
