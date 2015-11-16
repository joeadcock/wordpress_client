require "spec_helper"

module Wpclient
  describe Connection do
    subject(:connection) {
      Connection.new(url: "http://example.com/", username: "jane", password: "doe")
    }

    let(:base_url) { "http://jane:doe@example.com/wp/v2" }
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
        request_stub = stub_request(:get, "#{base_url}/foo?some_param=12").to_return(
          body: '{"foo":"here"}',
          headers: {"content-type" => "application/json; charset=utf-8"},
        )
        expect(model).to receive(:parse).with("foo" => "here").and_return(model_instance)
        expect(connection.get(model, "foo", some_param: 12)).to eq model_instance
        expect(request_stub).to have_been_made
      end

      it "can get several models" do
        request_stub = stub_request(:get, "#{base_url}/foos?some_param=12").to_return(
          body: '["result"]',
          headers: {"content-type" => "application/json; charset=utf-8"},
        )
        expect(model).to receive(:parse).with("result").and_return(model_instance)
        expect(connection.get_multiple(model, "foos", some_param: 12)).to eq [model_instance]
        expect(request_stub).to have_been_made
      end
    end

    describe "creating" do
      it "can create models" do
        encoding = "".encoding

        stub_request(:post, "#{base_url}/foos").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"title" => "Bar"}.to_json,
        ).to_return(
          status: 201, # Created
          headers: {
            "Content-Type" => "application/json; charset=utf-8",
            "Location" => "#{base_url}/foos/1"
          }
        )

        stub_request(:get, "#{base_url}/foos/1").to_return(
          headers: {"content-type" => "application/json; charset=utf-8"},
          body: {id: 1, title: "Bar"}.to_json,
        )

        expect(model).to receive(:parse).with(
          "id" => 1, "title" => "Bar"
        ).and_return(model_instance)

        response = connection.create(model, "foos", title: "Bar")
        expect(response).to eq model_instance
      end

      it "can ignore the response" do
        encoding = "".encoding

        stub_request(:post, "#{base_url}/foos").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"title" => "Bar"}.to_json,
        ).to_return(
          status: 201, # Created
          headers: {
            "Content-Type" => "application/json; charset=utf-8",
            "Location" => "#{base_url}/foos/1"
          }
        )

        response = connection.create_without_response("foos", title: "Bar")
        expect(response).to be true
      end

      it "can pass extra parameters when following redirect" do
        encoding = "".encoding

        stub_request(:post, "#{base_url}/foos").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"title" => "Bar"}.to_json,
        ).to_return(
          status: 201, # Created
          headers: {
            "Content-Type" => "application/json; charset=utf-8",
            "Location" => "#{base_url}/foos/1"
          }
        )

        redirect = stub_request(:get, "#{base_url}/foos/1?extra=param").to_return(
          headers: {"content-type" => "application/json; charset=utf-8"},
          body: "{}",
        )

        connection.create(model, "foos", {title: "Bar"}, redirect_params: {extra: "param"})
        expect(redirect).to have_been_made
      end
    end

    describe "patching" do
      it "can patch models" do
        encoding = "".encoding

        stub_request(:patch, "#{base_url}/foos/1").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"title" => "Bar"}.to_json,
        ).to_return(
          headers: {"content-type" => "application/json; charset=utf-8"},
          body: {id: 1, title: "Bar"}.to_json,
        )

        expect(model).to receive(:parse).with(
          "id" => 1, "title" => "Bar"
        ).and_return(model_instance)

        response = connection.patch(model, "foos/1", title: "Bar")
        expect(response).to eq model_instance
      end

      it "can ignore responses" do
        encoding = "".encoding

        stub_request(:patch, "#{base_url}/foos/1").with(
          headers: {"content-type" => "application/json; charset=#{encoding}"},
          body: {"title" => "Bar"}.to_json,
        ).to_return(
          headers: {"content-type" => "application/json; charset=utf-8"},
          body: {id: 1, title: "Bar"}.to_json,
        )

        response = connection.patch_without_response("foos/1", title: "Bar")
        expect(response).to be true
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
    end
  end
end
