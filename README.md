# Uncle

### Experimental!

Uncle depends on my Rails fork because it uses a different router to reflect on the route set

### Ruby on Rails URL helpers for relative resources

Helpers methods that reflect on your application route set to dynamically infer
correct URLs for parent and nested child resources.

Given a routes.rb containing: 

```ruby
Dummy::Application.routes.draw do
  resources :widgets, except: %i<new edit> do
    resources :gizmos, except: %i<new edit>
    resources :doo_dads, except: %i<new edit>
  end

  resources :thingies, except: %i<new edit>
end
```

and the controllers

```ruby
class GizmosController < ApplicationController
  def index
    render json: parent_resource
  end
end
```

```ruby
class ThingiesController < ApplicationController
  def show
    render json: parent_resource
  end
end

```

```ruby
class WidgetsController < ApplicationController
  def index
    head :ok
  end

  def show
    render json: child_resources
  end
end
```

Then:

```
GET /widgets/1/gizmos returns { 'widgets': 'http://example.org/widgets/1' }

GET /widgets/1 returns { 'gizmos': 'http://example.org/widgets/1/gizmos', 'doo_dads': 'http://example.org/widgets/1/doo_dads' }

GET /thingies/1` returns `{ 'thingy': 'http://example.org/thingies' }
```
