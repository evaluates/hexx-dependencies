# encoding: utf-8

describe Hexx::Dependencies::CLI, :sandbox, :capture do

  describe ".start" do

    subject { try_in_sandbox { described_class.start params } }

    shared_examples "creating a loader mechanism" do

      before { subject }

      it "[adds dummy loader]" do
        content = read_in_sandbox "spec/spec_helper.rb"
        expect(content).to include "require_relative \"dummy/lib/dummy\""
      end

      it "[adds dummy lib]" do
        content = read_in_sandbox "spec/dummy/lib/dummy.rb"
        expect(content).to include "ENV[\"PATH_TO_INITIALIZERS\"] ="
        expect(content).to include "\"../../config/initializers\""
        expect(content).to include "require \"sandbox\""
      end

      it "[adds the initializer]" do
        content = read_in_sandbox "spec/dummy/config/initializers/sandbox.rb"
        expect(content).to include "Sandbox.configure do"
      end

      it "[adds gem configurator]" do
        content = read_in_sandbox "lib/sandbox/configurator.rb"
        expect(content).to include "class << self"
        expect(content).to include "def configure"
      end

      it "[adds gem lib]" do
        content = read_in_sandbox "lib/sandbox.rb"
        expect(content).to include "require_relative \"sandbox/configurator\""
        expect(content).to include "ENV[\"PATH_TO_INITIALIZERS\"]"
        expect(content).to include "sandbox.rb"
      end

    end # shared_examples

    shared_examples "providing a dependency" do

      before { subject }

      it "[adds the attribute]" do
        content = read_in_sandbox "lib/sandbox/configurator.rb"
        expect(content).to include "attr_accessor :#{ name }"
      end

    end # shared_examples

    shared_examples "injecting a dependency" do

      before { subject }

      it "[adds gem]" do
        content = read_in_sandbox "Gemfile"
        expect(content).to include "gem \"#{ gemname }\", group: :test"
      end

      it "[adds injection]" do
        content = read_in_sandbox "spec/dummy/config/initializers/sandbox.rb"
        expect(content).to include "require \"#{ gemname }\""
        expect(content).to include "#{ name } = #{ injection }"
      end

    end # shared_examples

    context "without params" do

      let(:params) { %w() }

      it_behaves_like "creating a loader mechanism"

    end # context

    context "foo" do

      let(:params) { %w(foo) }

      it_behaves_like "creating a loader mechanism"

      it_behaves_like "providing a dependency" do
        let(:name) { "foo" }
      end

    end # context

    context "foo -i bar -g baz" do

      let(:params) { %w(foo -i bar -g baz) }

      it_behaves_like "creating a loader mechanism"

      it_behaves_like "providing a dependency" do
        let(:name) { "foo" }
      end

      it_behaves_like "injecting a dependency" do
        let(:name)      { "foo" }
        let(:injection) { "Bar" }
        let(:gemname)   { "baz" }
      end

    end # context

    context "foo -i Bar" do

      let(:params) { %w(foo -i Bar) }

      it_behaves_like "creating a loader mechanism"

      it_behaves_like "providing a dependency" do
        let(:name) { "foo" }
      end

    end # context

    context "foo -g baz" do

      let(:params) { %w(foo -g baz) }

      it_behaves_like "creating a loader mechanism"

      it_behaves_like "providing a dependency" do
        let(:name) { "foo" }
      end

    end # context

    context "-i bar -g baz" do

      let(:params) { %w(-i bar -g baz) }

      it_behaves_like "creating a loader mechanism"

    end # context

  end # describe .start

end # describe Hexx::Dependencies::CLI
