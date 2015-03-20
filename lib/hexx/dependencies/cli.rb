# encoding: utf-8

module Hexx

  module Dependencies

    class CLI < Hexx::CLI::Base

      def self.source_root
        ::File.expand_path "../cli", __FILE__
      end

      desc "Scaffolds the dependency from a variable defined outside of the gem"
      namespace :dependency

      argument(
        :name,
        banner: "NAME",
        default: "",
        desc: "The name of the dependency",
        type: :string
      )

      class_option(
        :injection,
        aliases: "-i",
        banner:  "Injection",
        desc: "The name of the dependency implementation injected by the dummy",
        required: false,
        type: :string
      )

      class_option(
        :gemname,
        aliases: "-g",
        banner:  "gemname",
        desc: "The name of the gem for dummy to inject the dependency from",
        required: false,
        type: :string
      )

      # @private
      def add_dummy_loader
        template "spec_helper.erb", "spec/spec_helper.rb", skip: true
        gsub_file(
          "spec/spec_helper.rb",
          /require\s+"#{ project.file }"/,
          "require_relative \"dummy/lib/dummy\""
        )
      end

      # @private
      def add_dummy_lib
        template "dummy.erb", "spec/dummy/lib/dummy.rb", skip: true
      end

      # @private
      def add_initializer
        template(
          "initializer.erb",
          "spec/dummy/config/initializers/#{ project.file }.rb",
          skip: true
        )
      end

      # @private
      def add_configurator
        template(
          "configurator.erb",
          "lib/#{ project.path }/configurator.rb",
          skip: true
        )
      end

      # @private
      def add_lib
        template "lib.erb", "lib/#{ project.path }.rb", skip: true
        insert_into_file(
          "lib/#{ project.path }.rb",
          from_template("lib_loader.erb"),
          after: /\n\s*module #{ project.const }\n/
        )
      end

      # @private
      def add_dependency
        return unless dependency?
        insert_into_file(
          "lib/#{ project.path }/configurator.rb",
          from_template("dependency.erb"),
          after: "class << self\n"
        )
      end

      # @private
      def add_gemfile
        return unless injection?
        copy_file "Gemfile", skip: true
        append_to_file "Gemfile", "gem \"#{ gemname }\", group: :test"
      end

      # @private
      def add_injection
        return unless injection?
        insert_into_file(
          "spec/dummy/config/initializers/#{ project.file }.rb",
          "\nrequire \"#{ gemname }\"",
          before: /\n*#{ project.type }/,
          skip: true
        )
      end

      # @private
      def set_injection
        return unless injection?
        insert_into_file(
          "spec/dummy/config/initializers/#{ project.file }.rb",
          "\n  #{ dependency } = #{ injection }",
          before: /\nend/,
          skip: true
        )
      end

      private

      def project
        @project ||= Hexx::CLI::Name.new ::File.basename(destination_root)
      end

      def dependency
        @dependency ||= (name == "") ? nil : name.to_s.snake_case
      end

      def injection
        @injection ||= options.fetch("injection", "").camel_case
      end

      def gemname
        @gemname ||= options.fetch("gemname", "").snake_case
      end

      def dependency?
        dependency ? true : false
      end

      def injection?
        dependency? && !injection.blank? && !gemname.blank?
      end

    end # module Hexx

  end # module Dependencies

end # class CLI
