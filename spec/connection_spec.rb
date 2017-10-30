require "spec_helper"

module WordpressClient
  describe Connection do
    subject(:connection) {
      Connection.new(url: "http://example.com/", username: "jane", password: "doe")
    }

    let(:base_url) { "http://example.com/wp/v2" }
    let(:model) { class_double(Post, parse: model_instance) }
    let(:model_instance) { instance_double(Post) }

    it "is constructed with a url, username and a password" do
      connection = Connection.new(url: "http://example.com/wp-json", username: "x", password: "x")
      expect(connection.url).to eq('http://example.com/wp-json')
    end

    it "does not show password when inspected" do
      connection = Connection.new(url: "/", username: "x", password: "secret")
      expect(connection.to_s).to_not include "secret"
      expect(connection.inspect).to_not include "secret"
    end

    describe "get" do
      it "can get a single model" do
        stub_get("#{base_url}/foo?some_param=12", returns: {title: "Foo"})
        expect(model).to receive(:parse).with("title" => "Foo").and_return(model_instance)
        expect(connection.get(model, "foo", some_param: 12)).to eq model_instance
      end

      it "can get several models" do
        stub_get("#{base_url}/foos?some_param=12&page=1&per_page=1", returns: ["result"], total: 1)

        expect(model).to receive(:parse).with("result").and_return(model_instance)

        expect(
          connection.get_multiple(model, "foos", some_param: 12, page: 1, per_page: 1).to_a
        ).to eq [model_instance]
      end

      it "paginates the result when fetching multiple models" do
        stub_get("#{base_url}/foos?page=4&per_page=15", returns: ["result"], total: 62)
        collection = connection.get_multiple(model, "foos", page: 4, per_page: 15)

        expect(collection).to be_instance_of(PaginatedCollection)
        expect(collection.total).to eq 62
        expect(collection.current_page).to eq 4
        expect(collection.per_page).to eq 15
      end

      it "raises WordpressClient::TimeoutError when requests time out" do
        stub_request(:get, /./).to_timeout
        expect { connection.get(model, "foo") }.to raise_error(TimeoutError)
        expect { connection.get_multiple(model, "foo") }.to raise_error(TimeoutError)
      end

      it "raises ServerError if response is invalid JSON" do
        stub_get(/./, body: "[")
        expect { connection.get(model, "foo") }.to raise_error(ServerError, /parse/)
        expect { connection.get_multiple(model, "foo") }.to raise_error(ServerError, /parse/)
      end

      it "raises ServerError if response is not application/json" do
        stub_get(/./, content_type: "text/plain")
        expect { connection.get(model, "foo") }.to raise_error(ServerError, /plain/)
        expect { connection.get_multiple(model, "foo") }.to raise_error(ServerError, /plain/)
      end

      it "raises NotFoundError if response is 404" do
        stub_get(/./, status: 404)
        expect { connection.get(model, "foo") }.to raise_error(NotFoundError)
        expect { connection.get_multiple(model, "foo") }.to raise_error(NotFoundError)
      end
    end

    describe "creating" do
      it "can create models" do
        stub_successful_post_with_redirect(
          "#{base_url}/foos", {title: "Bar"}, redirects_to: "#{base_url}/foos/1"
        )
        stub_get("#{base_url}/foos/1", returns: {id: 1, title: "Bar"})

        expect(model).to receive(:parse).with(
          "id" => 1, "title" => "Bar"
        ).and_return(model_instance)

        response = connection.create(model, "foos", title: "Bar")
        expect(response).to eq model_instance
      end

      it "can ignore the response" do
        stub_successful_post_with_redirect(
          "#{base_url}/foos", {title: "Bar"}, redirects_to: "#{base_url}/foos/1"
        )

        response = connection.create_without_response("foos", title: "Bar")
        expect(response).to be true
      end

      it "can pass extra parameters when following redirect" do
        stub_successful_post_with_redirect(
          "#{base_url}/foos", {title: "Bar"}, redirects_to: "#{base_url}/foos/1"
        )
        redirect = stub_get("#{base_url}/foos/1?extra=param", returns: {})

        connection.create(model, "foos", {title: "Bar"}, redirect_params: {extra: "param"})
        expect(redirect).to have_been_made
      end

      it "raises NotFoundError if response is 400 with rest_post_invalid_id as error code" do
        stub_failing_post(/./, returns: json_fixture("invalid-post-id.json"), status: 400)

        expect { connection.create(model, "foo", {}) }.to raise_error(NotFoundError, /post id/i)
        expect { connection.create_without_response("foo", {}) }.to raise_error(NotFoundError)
      end

      it "raises ValidationError on any other 400 responses" do
        stub_failing_post(/./, returns: json_fixture("validation-error.json"), status: 400)

        expect {
          connection.create(model, "foo", {})
        }.to raise_error(ValidationError, /status is not one of/)

        expect {
          connection.create_without_response("foo", {})
        }.to raise_error(ValidationError, /status is not one of/)
      end
    end

    describe "patching" do
      it "can patch models" do
        stub_patch("#{base_url}/foos/1", {title: "Bar"}, returns: {id: 1, title: "Bar"})

        expect(model).to receive(:parse).with(
          "id" => 1, "title" => "Bar"
        ).and_return(model_instance)

        response = connection.put(model, "foos/1", title: "Bar")
        expect(response).to eq model_instance
      end

      it "can ignore responses" do
        stub_patch("#{base_url}/foos/1", {title: "Bar"}, returns: {id: 1, title: "Bar"})
        response = connection.put_without_response("foos/1", title: "Bar")
        expect(response).to be true
      end

      it "raises NotFoundError if response is 400 with rest_post_invalid_id as error code" do
        stub_patch(/./, {}, returns: json_fixture("invalid-post-id.json"), status: 400)
        expect { connection.put(model, "foo", {}) }.to raise_error(NotFoundError, /post id/i)
        expect { connection.put_without_response("foo", {}) }.to raise_error(NotFoundError)
      end

      it "raises ValidationError on any other 400 responses" do
        stub_patch(/./, {}, returns: json_fixture("validation-error.json"), status: 400)

        expect {
          connection.put(model, "foo", {})
        }.to raise_error(ValidationError, /status is not one of/)

        expect {
          connection.put_without_response("foo", {})
        }.to raise_error(ValidationError, /status is not one of/)
      end
    end

    describe "deleting" do
      it "can delete paths" do
        encoding = "".encoding

        stub_request(:delete, "#{base_url}/foos/1").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"force" => true}.to_json,
        ).to_return(
          headers: {"content-type" => "application/json; charset=utf-8"},
          body: {status: "Heyhoo! Nice one!"}.to_json,
        )

        response = connection.delete("foos/1", force: true)
        expect(response).to be true
      end

      it "raises ValidationError on 400 responses" do
        stub_request(:delete, /./).to_return(
          status: 400,
          body: "{}",
          headers: {"content-type" => "application/json; charset=utf-8"},
        )

        expect {
          connection.delete("foo", {})
        }.to raise_error(ValidationError)
      end
    end

    describe "uploading" do
      it "posts the given IO and returns the resulting model" do
        stub_request(:post, "#{base_url}/files").with(
          headers: {
            "content-length" => "11",
            "content-type" => "text/plain",
            "content-disposition" => 'attachment; filename="foo.txt"',
          },
          body: "hello world",
        ).to_return(
          status: 201, # Created
          headers: {"Location" => "#{base_url}/files/67"}
        )
        stub_get("#{base_url}/files/67", returns: {id: 67})

        model_instance = double("some model instance")
        model = double("some model")

        expect(model).to receive(:parse).with("id" => 67).and_return model_instance

        result = connection.upload(
          model, "files", StringIO.new("hello world"), mime_type: "text/plain", filename: "foo.txt"
        )

        expect(result).to eq model_instance
      end
    end

    def stub_get(
      path,
      returns: {},
      status: 200,
      body: returns.to_json,
      total: nil,
      content_type: "application/json"
    )
      headers = {"content-type" => "#{content_type}; charset=utf-8"}
      headers["X-WP-Total"] = total.to_s if total

      stub_request(:get, path).with(basic_auth: ['jane', 'doe']).to_return(status: status, body: body, headers: headers)
    end

    def stub_successful_post_with_redirect(path, data, redirects_to:)
      stub_request(:post, path).with(
        basic_auth: ['jane', 'doe'],
        headers: {"content-type" => "application/json; charset=#{"".encoding}"},
        body: data.to_json,
      ).to_return(
        status: 201, # Created
        headers: {"Location" => redirects_to}
      )
    end

    def stub_failing_post(path, returns:, status:)
      stub_request(:post, path).with(
        basic_auth: ['jane', 'doe']
      ).to_return(
        status: status,
        body: returns.to_json,
        headers: {"content-type" => "application/json; charset=utf-8"},
      )
    end

    def stub_patch(path, data, returns:, status: 200)
      stub_request(:put, path).with(
        basic_auth: ['jane', 'doe'],
        headers: {"content-type" => "application/json; charset=#{"".encoding}"},
        body: data.to_json,
      ).to_return(
        status: status,
        headers: {"content-type" => "application/json; charset=utf-8"},
        body: returns.to_json,
      )
    end
  end
end
