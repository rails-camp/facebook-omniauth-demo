# Omniauth FB Example

## Build out the basic application

- Scaffold a basic application: `rails new app_name -T --database=postgresql`
- Create a set of pages
- Implement devise


## Setup a FB developer account

- [Link to create the account](https://developers.facebook.com/)
- Make sure to list your site URL in the setting's page, if only in development use something like: http://localhost:3000


## Integrate Omniauth

### Add to your Gemfile

```ruby
# Gemfile

gem 'omniauth-facebook'
```

### Update the User Table with the params needed

```ruby
rails g migration AddOmniauthToUsers provider:string uid:string name:string image:text
rails db:migrate
```

### Update initializer

```ruby
# config/initializers/devise.rb

config.omniauth :facebook, "App ID", "App Secret", callback_url: "http://localhost:3000/users/auth/facebook/callback"
```


### Update the model

```ruby
# app/models/user.rb

devise :omniauthable, :omniauth_providers => [:facebook]
```


### Add a Link to Facebook

```ruby
<!-- app/views/pages/home.html.erb -->

<% unless current_user %>
  <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
<% else %>
  <%= link_to "Logout", destroy_user_session_path, method: :delete %>
<% end %>
```


### Update Routes

```ruby
# config/routes.rb

devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
```


### Create a users directory

```
mkdir app/controllers/users
```


### Create a users controller

```ruby
# app/controller/users/omniauth_callbacks_controller.rb

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
```


### Add custom methods to the User model

```ruby
# app/models/user.rb

def self.new_with_session(params, session)
  super.tap do |user|
    if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
      user.email = data["email"] if user.email.blank?
    end
  end
end

def self.from_omniauth(auth)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    user.name = auth.info.name   # assuming the user model has a name
    user.image = auth.info.image # assuming the user model has an image
  end
end
```
