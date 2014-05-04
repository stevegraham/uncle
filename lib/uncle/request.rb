module Uncle
  class Request
    attr_reader :request, :routeset

    def initialize(request, routeset = Rails.application.routes)
      @request  = request
      @routeset = routeset
    end

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

    def child_resource_names(&blk)
      child_resource_paths(&blk).map do |path|
        node = node_for_path(path)
        name = routeset.recognize_path(path)[:controller]

        if node.children.any? { |n| n.key =~ /[._]?id\Z/ }
          name
        else
          name.singularize
        end
      end
    end

    def child_resource_urls(&blk)
      child_resource_paths(&blk).map do |path|
        request.protocol + request.host_with_port + path
      end
    end

    def child_resource_paths(&blk)
      key_paths = child_resource_nodes.map(&:to_key_path)

      params[:"#{resource_name}_id"] = params.delete(:id) if params.has_key?(:id)

      key_paths.map! do |kp|
        kp.map! { |segment| params[segment.tr(':', '').to_sym] || segment }.join('/')
      end

      if block_given?
        key_paths.select { |p| blk.call routeset.recognize_path(p) }
      else
        key_paths
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

    def params
      @params ||= routeset.recognize_path(request.path)
    end

    def resource_name
      params[:controller].singularize
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
