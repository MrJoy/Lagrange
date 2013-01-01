describe Lagrange::Models::AutoVivifyingOpenStruct do
  def recursively_check(avos)
    table = avos.instance_variable_get(:'@table')
    table.each do |key, value|
      key.should be_a Symbol
      value.should_not be_a Hash
      if(value.is_a?(Lagrange::Models::AutoVivifyingOpenStruct))
        recursively_check(value)
      elsif(value.is_a?(Fixnum))
        value.should eq 123
      elsif(value.is_a?(String))
        value.should eq "something"
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
      s.foo.bar.baz.blah.should eq 123
      s.foo.bar.meh.should eq 123
    end

  end

  describe "#as_json" do
    it "should convert the entire hierarchy into a simple hash" do
      s = Lagrange::Models::AutoVivifyingOpenStruct.new(foo: { bar: { baz: { blah: 123 }}}).as_json

      s.should be_a(Hash)
      s.keys.should == [:foo]
      s[:foo].should be_a(Hash)
      s[:foo].keys.should == [:bar]
      s[:foo][:bar].should be_a(Hash)
      s[:foo][:bar].keys.should == [:baz]
      s[:foo][:bar][:baz].should be_a(Hash)
      s[:foo][:bar][:baz].keys.should == [:blah]
      s[:foo][:bar][:baz][:blah].should eq 123
    end
  end
end
