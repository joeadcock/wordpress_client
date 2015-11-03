# wpclient

wpclient is a simple client to the Wordpress API.

## Usage

Initialize a client with a username, password and API URL. You can then search for posts.

```ruby
client = Wpclient.new(url: "https://example.com/wp-json/", username: "example", password: "example")

client.posts(per_page: 5) # => [Wpclient::Post, Wpclient::Post]
```

### Creating a post

You can create posts by calling `create_post`. If you supply a ID, the article will be created using `PUT` instead of `POST`.

```ruby
data = {
  author: "Name",
  # ...
}

# POSTs the data and gets the result back
post = client.create_post(data) # => Wpclient::Post

# PUT the same data on the newly created post.
client.create_post(data.merge(id: post.id))
```

## Running tests

You need to install Docker and set it up for your machine. Note that you need `docker-machine` to run Docker on OS X.

Run tests using the normal `rspec` command after installing all bundles. The first time the integration tests are run, a docker image will be built that hosts a Wordpress installation, but the image will be re-used on subsequent runs.

```
bundle exec rspec
```

## Copyright & License

Copyright © 2015 Hemnet Service HNS AB

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
