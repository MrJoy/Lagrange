describe Lagrange::Models::AutoVivifyingOpenStruct do
  def recursively_check(avos)
    table = avos.instance_variable_get(:'@table')
    table.each do |key, value|
      expect(key).to be_a Symbol
      expect(value).not_to be_a Hash
      if(value.is_a?(Lagrange::Models::AutoVivifyingOpenStruct))
        recursively_check(value)
      elsif(value.is_a?(Fixnum))
        expect(value).to eq 123
      elsif(value.is_a?(String))
        expect(value).to eq "something"
      end
    end
  end

  describe "#new" do
    it "should accept a hash" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new(foo: "something", "baz" => 123)

      recursively_check(s)
    end

    it "should recursively turn a deep hash into auto-vivifying structs" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new(foo: { bar: { baz: { blah: 123 }}})

      recursively_check(s)
    end
  end

  describe "#method_missing" do
    it "should auto-vivify arbitrarily deep properties" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo.bar.baz.blah = 123

      recursively_check(s)
    end

    it "should recursively convert hashes that are assigned as values" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo = { bar: { baz: { blah: 123 } } }

      recursively_check(s)
    end

    it "should recursively convert hashes that are assigned as values, even when replacing a value" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo = { bar: 123 }
      s.foo.bar = { baz: { blah: 123 } }

      recursively_check(s)
    end
  end

  describe "#merge!" do
    it "should recursively convert the provided hash" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo.bar = { baz: { blah: 123 } }
      s.foo.bar.merge!(whatever: { meh: 123 })

      recursively_check(s)
    end

    it "should not care whether keys are symbols or strings" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo.bar = { baz: { blah: 123 } }
      s.foo.bar.merge!("whatever" => { "meh" => 123 }, "baz" => "something")

      recursively_check(s)
    end

    it "should perform a deep merge gracefully" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new
      s.foo = { bar: { baz: { blah: 123 } } }
      s.foo.merge!({ bar: { meh: 123 }})

      recursively_check(s)
      expect(s.foo.bar.baz.blah).to eq 123
      expect(s.foo.bar.meh).to eq 123
    end

  end

  describe "#as_json" do
    it "should convert the entire hierarchy into a simple hash" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new(foo: { bar: { baz: { blah: 123 }}}).as_json

      expect(s).to be_a(Hash)
      expect(s.keys).to eq([:foo])
      expect(s[:foo]).to be_a(Hash)
      expect(s[:foo].keys).to eq([:bar])
      expect(s[:foo][:bar]).to be_a(Hash)
      expect(s[:foo][:bar].keys).to eq([:baz])
      expect(s[:foo][:bar][:baz]).to be_a(Hash)
      expect(s[:foo][:bar][:baz].keys).to eq([:blah])
      expect(s[:foo][:bar][:baz][:blah]).to eq 123
    end
  end
end
