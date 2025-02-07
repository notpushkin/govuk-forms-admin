require "rails_helper"

RSpec.describe Organisation, type: :model do
  it "is an error to create an organisation with an existing slug" do
    organisation = create(:organisation, slug: "duplicate-org")

    expect {
      described_class.create!(govuk_content_id: Faker::Internet.uuid, slug: organisation.slug, name: organisation.name)
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  describe "factory" do
    it "does not create organisation if already exists" do
      existing_organisation = create(:organisation, slug: "duplicate-org")
      new_organisation = nil

      expect {
        new_organisation = create(:organisation, slug: "duplicate-org")
      }.not_to raise_error

      expect(new_organisation).to eq(existing_organisation)
    end
  end

  describe "versioning", versioning: true do
    it "enables paper trail" do
      expect(described_class.new).to be_versioned
    end
  end
end
