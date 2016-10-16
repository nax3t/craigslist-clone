# Craigslist Clone

## Features
- Image upload: [paperclip](https://github.com/thoughtbot/paperclip) (gem)
- Image upload requires [ImageMagick](https://github.com/thoughtbot/paperclip#image-processor)
- [Google Maps API](https://developers.google.com/maps/web/): with the [geocoder](https://github.com/alexreisner/geocoder) (gem)
- [Figaro](https://github.com/laserlemon/figaro): for hiding API key (and other sensitive data)

### Models
- User
	- email
	- password 
- Post
	- title
	- cost
	- body
	- image
	- address
	- latitude
	- longitude
	- user_id
	
# Instructions
## Day 1 Image Upload
- `rails new craigslist-clone`
- `cd craigslist-clone`
- `git init` (add and commit)
- [Setup User authentication](http://guides.railsgirls.com/devise) with [Devise](https://github.com/plataformatec/devise)
- Add [paperclip](https://github.com/thoughtbot/paperclip#installation) to Gemfile and `bundle install`
- Generate Post model
	- `rails g model Post title cost:decimal body:text`
	- `rails g paperclip post image`
	- `rake db:migrate`
- Add paperclip code for image to Post model

```ruby
has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
``` 
- Generate posts_controller
	- `rails g controller Posts index new show edit`
- Add post routes to `config/routes.rb` using the resources heler and remove default generated routes
	- `resources :posts`
- Add [simple_form](https://github.com/plataformatec/simple_form) to Gemfile
	- `rails g simple_form:install --bootstrap`
- Add new form for Post

```ruby
<%= simple_form_for @post do |f| %>
  <%= f.input :title %>
  <%= f.input :cost %>
  <%= f.input :body %>
  <%= f.input :image, as: :file %>
  
  <%= f.button :submit %>
<% end %>
``` 

- Add `post_params` and `create` action to posts_controller

- Install [ImageMagick](https://github.com/thoughtbot/paperclip#image-processor)
	- mac - `brew install imagemagick`
	- c9 - `sudo apt-get install imagemagick -y`
- Fire up your app and navigate to `localhost:3000/posts/new`, create a new post
- Edit your `posts_controller` `show` action and `posts/show.html.erb` view to display the Post info
	- use `number_to_currency` and `image_tag` to render the cost and the image
	
## Day 2 Google Maps
- Add figaro gem to Gemfile
	- `gem figaro`
	- Run `bundle`
	- Run `bundle exec figaro install`
- Create a new project in [Google Maps API](https://developers.google.com/maps/web/) and get a key
- Open `config/application.yml` and add your key as an environment (ENV) variable
	- `maps_api_key: <your_key_here>`
	- open `application.html.erb` and add the following script to the bottom of the head tag:
	
```js
 <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=<%= ENV['maps_api_key'] %>">
 </script>
```

- Add a div to render the map onto your `posts/show.html.erb` view:

```html
<div id="map-container">
  <div id="map-canvas"></div>
</div>
```

- Open `assets/stylesheets/posts.scss`, rename the file to be `posts.css` and add the following CSS:
```css
#map-container {
	height: 400px;
	border-radius: 16px 16px;
	border-color: #fff;
	border-style: solid;
	box-shadow: 2px 2px 10px #B1B1B1;
	margin-top: 25px;
	border-width: 7px;
}

#map-canvas {
	height: 384px;
	width: 100%;
}
```
- Open `assets/javascripts/posts.coffee`, rename the file to be `posts.js` and add the following code:
```js
$(document).ready(function (){

	function initialize() {
	   var myLatlng = new google.maps.LatLng(33.784624, -84.422030);

		var mapOptions = {
			zoom: 15,
			center: myLatlng,
			scrollwheel: false    
		}

		var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

		var marker = new google.maps.Marker({
			position: myLatlng,
			map: map,
			animation: google.maps.Animation.DROP
		});

	}

	google.maps.event.addDomListener(window, 'load', initialize);
});
```
- Now we need to give our Post model an address property and connect it to the map
- Generate a new migration for the posts table: `rails g migration AddCoordinatesToPosts latitude:float longitude:float address:string` then run `rake db:migrate`
- Now add the address property to our `posts/new.html.erb` form:
```ruby
<%= simple_form_for @post do |f| %>
  <%= f.input :title %>
  <%= f.input :cost %>
  <%= f.input :body %>
  <%= f.input :image, as: :file %>
  <%= f.input :address %>  
  
  <%= f.button :submit %>
<% end %>
```
- Whitelist the new properties in your posts controller:
```ruby
def post_params
	params.require(:post).permit(:title, :cost, :body, :image, :latitude, :longitude, :address)
end
```
- Now add the [geocoder](https://github.com/alexreisner/geocoder) gem:
    - Add `gem geocoder` to `Gemfile` and run `bundle`
- Add the following code to your Post model (`models/post.rb`), right after the paperclip code that we added earlier:
```ruby
geocoded_by :address
after_validation :geocode
```
- To render the address and marker onto the map we'll need to set the JavaScript variables using Rail's [javascript_tag](http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-javascript_tag), add the following code to the bottom of `posts/show.ejs`
```ruby
<%= javascript_tag do %>
	latitude = '<%= j @post.latitude.to_s %>';
	longitude = '<%= j @post.longitude.to_s %>';
	title = '<%= j @post.title %>';
	cost = '<%= j number_to_currency(@post.cost) %>';
	address = '<%= j @post.address %>';
<% end %>
```
- I went ahead and included the title, cost, and address so we could render them onto the marker as an info window
    - Update your `assets/javascripts/posts.js` file with the following:
```js
$(document).ready(function (){

	function initialize() {
		var myLatlng = new google.maps.LatLng(latitude, longitude);

		var mapOptions = {
			zoom: 15,
			center: myLatlng,
			scrollwheel: false    
		}

		var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

		var marker = new google.maps.Marker({
			position: myLatlng,
			map: map,
			animation: google.maps.Animation.DROP
		});

		var contentString = '<h1>' + title + '</h1>'+
												'<p>' + cost + '</p>'+
												'<p>' + address + '</p>';

		var infowindow = new google.maps.InfoWindow({
			content: contentString
		});

		marker.addListener('click', function() {
			infowindow.open(map, marker);
		});
	}

	google.maps.event.addDomListener(window, 'load', initialize);
});
```
- Open up `rails console` and delete all pre-exisiting posts with `Post.destroy_all` now close rails console, run your `rails server` and create a new post.
