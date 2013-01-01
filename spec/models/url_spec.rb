describe Lagrange::Models::URL do
  describe "#new" do
    describe "when given an empty parameter list" do
      before(:each) do
        @url = Lagrange::Models::URL.new
      end

      it "should exist" do
        @url.should_not be_nil
      end

      it "should not be valid" do
        @url.valid?.should eq false
      end

      it "should have created/updated at timestamps" do
        @url.created_at.should_not be_nil
        @url.updated_at.should_not be_nil
      end

      # TODO: In test mode, don't read from the real repository -- use a dummy
      # TODO: config, and so forth.
      RAW_URL = 'http://foo.com?utm_campaign=meh&foo=bar#baz'
      CANONICAL_URL = 'http://foo.com/?utm_campaign=meh&foo=bar#baz'
      CLEANSED_URL = 'http://foo.com/?foo=bar#baz'
      UUID = '4c5f8356bff4b67f3bdd7b2d4d8c6a2818f71dec'
      it "should allow assignment of raw_url, which should create uuid, etc" do
        @url.raw_url = RAW_URL

        @url.raw_url.should eq RAW_URL
        @url.canonical_url.should eq CANONICAL_URL
        @url.cleansed_url.should eq CLEANSED_URL
        @url.uuid.should eq UUID
      end
    end
  end
end
