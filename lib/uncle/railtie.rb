module Uncle
  class Railtie < Rails::Railtie
    initializer 'uncle.initialize' do
      ActionController::Base.send :include, Uncle::ResourceUrls

      ActionDispatch::Routing::Trie::Node.class_eval do
        def to_key_path
          @parent ? @parent.to_key_path.push(@key) : [@key]
        end
      end

      ActionDispatch::Routing::RouteSet::Dispatcher.class_eval do
        attr_reader :defaults
      end
    end
  end
end
