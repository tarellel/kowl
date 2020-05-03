This is a simple walkthrough on how to enable ActionText/[Trix](https://github.com/basecamp/trix) with simpleform.
This walk-through enables you to use trix on the Posts scaffold form, as well manage the posts content in an Administrate dashboard page.


Generate a new application with kowl, with [simple_form](https://github.com/heartcombo/simple_form) enabled to easily generate forms.

`kowl testapp --simpleform; cd testapp; code .;`

After the application template has finished, we need to generate a posts scaffold that will use action text

```shell
rails g scaffold Posts title:string body:rich_text
rails db:migrate
```

Since we're using Pundit to help enforce authorization policies, well need to generate a pundit policy for accessing and modifying posts. To do this lets generate a posts policy:

```shell
rails g pundit:policy post
```

Copy the following snip into your `app/policies/post_policy.rb` file to allow admin users to modify and create posts.

```ruby
class PostPolicy < ApplicationPolicy
  def index?
    admin? || staff?
  end

  # Post should not be create-able, unless the currently logged in user is an admin
  def new?
    admin?
  end

  def create?
    admin?
  end

  def show?
    admin? || staff?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end
end
```


```ruby
# In config/routes.rb add the posts resources to the admin namespace
namespace :admin do
  resources :users
  resources :login_activities
  resources :posts
  root to: "users#index"
end
```

Generate a posts dashboard `rails g administrate:dashboard Post`
And add the body attribute through (it's a virtual attribute passed from ActionText) and you need to set the body attribute_type as `RichTextAreaField` so it'll use the custom `RichTextAreaField` field type.

```ruby
require 'administrate/base_dashboard'

class PostDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    body: RichTextAreaField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title body created_at].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id title body created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[title body].freeze
  COLLECTION_FILTERS = {}.freeze
end
```

Change the `:body` attribute from a text field to use `rich_text_area` simple_form attribute in `app/views/posts/_form.html.erb`

```ruby
# Original field
<%= f.input :body %>

# Change it to
<%= f.input :body, as: :rich_text_area %>
```

Now goto localhost:3000/posts and create posts with trix/ActionText