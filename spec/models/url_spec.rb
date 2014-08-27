describe Lagrange::Models::URL do
  describe "#new" do
    describe "when given an empty parameter list" do
      before(:each) do
        @url = Lagrange::Models::URL.new
      end

      it "should exist" do
        expect(@url).not_to be_nil
      end

      it "should not be valid" do
        expect(@url.valid?).to eq false
      end

      it "should have created/updated at timestamps" do
        expect(@url.created_at).not_to be_nil
        expect(@url.updated_at).not_to be_nil
      end

      # TODO: In test mode, don't read from the real repository -- use a dummy
      # TODO: config, and so forth.
      RAW_URL = 'http://foo.com?utm_campaign=meh&foo=bar#baz'
      CANONICAL_URL = 'http://foo.com/?utm_campaign=meh&foo=bar#baz'
      CLEANSED_URL = 'http://foo.com/?foo=bar#baz'
      UUID = '4c5f8356bff4b67f3bdd7b2d4d8c6a2818f71dec'
      it "should allow assignment of raw_url, which should create uuid, etc" do
        @url.raw_url = RAW_URL

        expect(@url.raw_url).to eq RAW_URL
        expect(@url.canonical_url).to eq CANONICAL_URL
        expect(@url.cleansed_url).to eq CLEANSED_URL
        expect(@url.uuid).to eq UUID
      end
    end
  end
end
