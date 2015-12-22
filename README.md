# WordpressClient

WordpressClient is a very simple client for the Wordpress [WP REST API plugin][api] (version 2 beta 8.0).

[![Circle CI](https://circleci.com/gh/hemnet/wordpress_client.svg?style=svg)](https://circleci.com/gh/hemnet/wordpress_client) [![Code Climate](https://codeclimate.com/repos/5645938269568041da00cded/badges/5e870b57428f23c1f2ff/gpa.svg)](https://codeclimate.com/repos/5645938269568041da00cded/feed) [![Test Coverage](https://codeclimate.com/repos/5645938269568041da00cded/badges/5e870b57428f23c1f2ff/coverage.svg)](https://codeclimate.com/repos/5645938269568041da00cded/coverage) [![Gem Version](https://badge.fury.io/rb/wordpress_client.svg)](https://badge.fury.io/rb/wordpress_client)[![Dependency Status](https://gemnasium.com/hemnet/wordpress_client.svg)](https://gemnasium.com/hemnet/wordpress_client)

## Usage

**[Read the full API documentation][docs]**

Initialize a client with a user name, password and API URL. You can then search for posts.

```ruby
client = WordpressClient.new(url: "https://example.com/wp-json/", username: "example", password: "example")

client.posts(per_page: 5) # => [WordpressClient::Post, WordpressClient::Post]
```

### Creating a post

You can create posts by calling `create_post`. If you supply a ID, the article will be created using `PUT` instead of `POST`.

```ruby
data = {
  author: "Name",
  # ...
}

post = client.create_post(data) # => WordpressClient::Post
updated_post = client.update_post(post.id, title: "Updated") # => WordpressClient::Post

updated_post.title_html # => "Updated"
```

## Running tests

You need to install Docker and set it up for your machine. Note that you need `docker-machine` to run Docker on OS X.

Run tests using the normal `rspec` command after installing all bundles.

```
bundle exec rspec
```

You can also run `bundle exec guard` to have tests run automatically when you change files in the repo. If you tag your examples with `focus: true`, Guard will only run those tests. This can help when doing very focused coding, but remember to remove the filter before you commit and let the entire suite run.

```ruby
describe Foo, focus: true do
  # ...
end
```

The normal `rspec` command will *not* use this filter in case it is ever committed accidentally, so CI can catch any problems.

## Releasing a new version

The normal gem release cycle works using `rake release`.

If you make changes to the docker image, you can release it using `rake docker:release`.

## Copyright & License

Copyright © 2015 Hemnet Service HNS AB

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[api]: http://v2.wp-api.org/
[docs]: http://www.rubydoc.info/gems/wordpress_client/
