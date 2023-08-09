require "rails_helper"

RSpec.describe Pages::AdditionalGuidanceForm, type: :model do
  let(:additional_guidance_form) { described_class.new(page_heading:, additional_guidance_markdown:) }
  let(:page_heading) { nil }
  let(:additional_guidance_markdown) { nil }

  describe "validations" do
    it "is invalid if page heading is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/additional_guidance_form.attributes.page_heading.blank")
      additional_guidance_form.page_heading = nil
      expect(additional_guidance_form).to be_invalid
      expect(additional_guidance_form.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
    end

    it "is invalid if additional_guidance_markdown is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/additional_guidance_form.attributes.additional_guidance_markdown.blank")
      additional_guidance_form.additional_guidance_markdown = nil
      expect(additional_guidance_form).to be_invalid
      expect(additional_guidance_form.errors.full_messages_for(:additional_guidance_markdown)).to include("Additional guidance markdown #{error_message}")
    end
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      expect(additional_guidance_form.submit(session_mock)).to eq false
      expect(additional_guidance_form.errors.any?).to eq true
    end

    context "when page_heading and additional_guidance_markdown are valid" do
      let(:page_heading) { "My new page heading" }
      let(:additional_guidance_markdown) { "Extra guidance needed to answer this question" }

      it "sets a session key called 'page' as a hash with the page heading in it" do
        additional_guidance_form.submit(session_mock)
        expect(session_mock[:page][:page_heading]).to eq page_heading
      end

      it "sets a session key called 'page' as a hash with the additional_guidance_markdown in it" do
        additional_guidance_form.submit(session_mock)
        expect(session_mock[:page][:additional_guidance_markdown]).to eq additional_guidance_markdown
      end
    end
  end
end
