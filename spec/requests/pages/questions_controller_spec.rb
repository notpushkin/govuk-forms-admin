require "rails_helper"

RSpec.describe Pages::QuestionsController, type: :request do
  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end
  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  let(:form_response) do
    (build :form, id: 2)
  end

  before do
    login_as_editor_user
  end

  describe "#new" do
    let(:req_headers) do
      {
        "X-API-Token" => Settings.forms_api.auth_key,
        "Accept" => "application/json",
      }
    end

    let(:post_headers) do
      {
        "X-API-Token" => Settings.forms_api.auth_key,
        "Content-Type" => "application/json",
      }
    end

    describe "Given a valid page" do
      let(:new_page_data) do
        {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: nil,
          answer_settings: nil,
          page_heading: nil,
          guidance_markdown: nil,
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, [].to_json, 200
          mock.post "/api/v1/forms/2/pages", post_headers
        end

        post create_question_path(2), params: { pages_question_form: {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: false,
        } }
      end

      it "Redirects you to a new type of answer page" do
        expect(response).to redirect_to(type_of_answer_new_path(form_id: 2))
      end

      it "Creates the page on the API" do
        expected_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/pages", new_page_data.to_json, post_headers)
        matched_request = ActiveResource::HttpMock.requests.find do |request|
          request.method == expected_request.method &&
            request.path == expected_request.path &&
            request.body == expected_request.body
        end

        expect(matched_request).to eq expected_request
      end
    end
  end

  describe "#edit" do
    describe "Given a page" do
      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          page_heading: nil,
          guidance_markdown: nil,
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
          page_heading: nil,
          guidance_markdown: nil,
        }.to_json
      end

      let(:req_headers) do
        {
          "X-API-Token" => Settings.forms_api.auth_key,
          "Accept" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page_response, 200
        end

        get edit_question_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_request

        form_pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_pages_request

        page_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include page_request
      end
    end
  end

  describe "#update" do
    describe "Given a page" do
      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        }.to_json
      end

      let(:updated_page_data) do
        {
          id: 1,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: nil,
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        }
      end

      let(:req_headers) do
        {
          "X-API-Token" => Settings.forms_api.auth_key,
          "Accept" => "application/json",
        }
      end

      let(:post_headers) do
        {
          "X-API-Token" => Settings.forms_api.auth_key,
          "Content-Type" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page_response, 200
          mock.put "/api/v1/forms/2/pages/1", post_headers
        end

        post update_question_path(form_id: 2, page_id: 1), params: { pages_question_form: {
          form_id: 2,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_request

        page_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include page_request
      end

      it "Updates the page on the API" do
        expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1", updated_page_data.to_json, post_headers)
        matched_request = ActiveResource::HttpMock.requests.find do |request|
          request.method == expected_request.method &&
            request.path == expected_request.path &&
            request.body == expected_request.body
        end

        expect(matched_request).to eq expected_request
      end

      it "Redirects you to the new type of answer page" do
        expect(response).to redirect_to(type_of_answer_create_path(form_id: 2))
      end
    end
  end
end
