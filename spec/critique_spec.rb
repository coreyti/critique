require 'spec_helper'

describe Critique do
  class ExampleClass
    include Critique
  end

  before do
    Critique.disable!
    # Critique.logger = '/dev/null'
  end

  it "is defined" do
    Critique.should be_a(Module)
  end

  context "when included" do
    it "defines .critique on the base class" do
      ExampleClass.should respond_to(:critique)
    end

    it "defines #critique on the base class" do
      ExampleClass.new.should respond_to(:critique)
    end
  end

  describe ".enabled?" do
    context "in the default state" do
      it "returns false" do
        Critique.should_not be_enabled
      end
    end

    context "when enabled" do
      before do
        Critique.enable!
      end

      it "returns true" do
        Critique.should be_enabled
      end
    end
  end

  describe ".critique" do
    let(:code) { 1 + 2 }

    context "when disabled" do
      it "does not execute profiling" do
        dont_allow(Critique::Profiling).profile
        ExampleClass.critique { code }
      end

      it "executes the code block" do
        result = ExampleClass.critique { code }
        result.should == 3
      end
    end

    context "when enabled" do
      before do
        Critique.enable!
      end

      it "executes profiling" do
        mock(Critique::Profiling).profile(ExampleClass, 2)
        ExampleClass.critique { code }
      end

      it "executes the code block" do
        ExampleClass.critique { code }.should == 3
      end
    end

    context "in the default (disabled) state" do
      it "does not run profiling" do
        dont_allow(Critique::Profiling).profile
        ExampleClass.critique { code }
      end
    end
  end
end
