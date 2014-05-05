module Uncle
  class Railtie < Rails::Railtie
    initializer 'uncle.initialize' do
      ActionController::Base.send :include, Uncle::Resource

      ActionDispatch::Routing::Trie::Node.class_eval do
        def to_key_path
          @parent ? @parent.to_key_path.push(@key) : [@key]
        end
      end
    end
  end
end
