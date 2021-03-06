#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/network/format_handler'

describe Puppet::Network::FormatHandler do
  before(:each) do
    @saved_formats = Puppet::Network::FormatHandler.instance_variable_get(:@formats).dup
    Puppet::Network::FormatHandler.instance_variable_set(:@formats, {})
  end

  after(:each) do
    Puppet::Network::FormatHandler.instance_variable_set(:@formats, @saved_formats)
  end

  describe "when creating formats" do
    it "should instance_eval any block provided when creating a format" do
      format = Puppet::Network::FormatHandler.create(:instance_eval) do
        def asdfghjkl; end
      end
      format.should respond_to(:asdfghjkl)
    end
  end

  describe "when retrieving formats" do
    let!(:format) { Puppet::Network::FormatHandler.create(:the_format, :extension => "foo", :mime => "foo/bar") }

    it "should be able to retrieve a format by name" do
      Puppet::Network::FormatHandler.format(:the_format).should equal(format)
    end

    it "should be able to retrieve a format by extension" do
      Puppet::Network::FormatHandler.format_by_extension("foo").should equal(format)
    end

    it "should return nil if asked to return a format by an unknown extension" do
      Puppet::Network::FormatHandler.format_by_extension("yayness").should be_nil
    end

    it "should be able to retrieve formats by name irrespective of case" do
      Puppet::Network::FormatHandler.format(:The_Format).should equal(format)
    end

    it "should be able to retrieve a format by mime type" do
      Puppet::Network::FormatHandler.mime("foo/bar").should equal(format)
    end

    it "should be able to retrieve a format by mime type irrespective of case" do
      Puppet::Network::FormatHandler.mime("Foo/Bar").should equal(format)
    end
  end
end
