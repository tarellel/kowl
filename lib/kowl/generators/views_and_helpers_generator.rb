# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class ViewsAndHelpersGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'app', 'views'), File.dirname(__FILE__))
    class_option :framework, type: :string, default: 'bootstrap'
    class_option :skip_pagination, type: :boolean, default: false
    class_option :simpleform, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean, default: false
    class_option :skip_turbolinks, type: :boolean, default: false
    class_option :template_engine, type: :string, default: 'erb'
    class_option :noauth, type: :boolean, default: false

    # Generate templates with framework and templae_engine with required application options
    def generate_templates
      # Generate views using bootstrap and semanic view generators
      gen_tags = []
      gen_tags.push("--template-engine=#{options[:template_engine]}")
      gen_tags.push('--simpleform') if options[:simpleform]
      gen_tags.push('--pagination') unless options[:skip_pagination]
      gen_tags.push('--devise') unless options[:noauth]
      gen_tags.push('--skip_javascript') if options[:skip_javascript]
      gen_tags.push('--skip_turbolinks') if options[:skip_turbolinks]
      gen_tags.push('--metatags')
      gen_tags.push('--layout')
      generate("#{options[:framework]}:install #{gen_tags.join(' ')}") if %w[bootstrap semantic].include? options[:framework]
    end

    # If template engine isn't set for erb remove application.erb
    def remove_application_layout
      remove_file 'app/views/layouts/application.html.erb' if %w[slim haml].include? options[:template_engine]
    end

    # Inject navigation header into application layout file based on template_engine/framework
    def inject_header_into_layout
      # prefix, includes, postfix
      # Pre and Postfix is determined if the template engine is ERB, Slim, or HAML
      nav_str = "#{template_prefix}= render 'shared/navigation'#{template_postfix}\n"
      match = { 'erb' => /\s\<body\>\n/,
                'haml' => /\s%body\n/,
                'slim' => /\sbody\n/ }
      insert_into_file "app/views/layouts/application.html.#{options[:template_engine]}", optimize_indentation(nav_str, 4), after: match[options[:template_engine]]
    end

    # Generate an application navigation view based on framework/template_engine
    def copy_navigation
      template("shared/navigation/#{options[:framework]}.html.#{options[:template_engine]}.tt", "app/views/shared/_navigation.html.#{options[:template_engine]}") if %w[bootstrap semantic].include? options[:framework]
    end

    # Generate an application footer view based on framework/template_engine
    def copy_footer
      template("shared/footer/#{options[:framework]}.html.#{options[:template_engine]}.tt", "app/views/shared/_footer.html.#{options[:template_engine]}") if %w[bootstrap semantic].include? options[:framework]
    end

    # Inject view template partial into application layout
    def inject_footer_into_layout
      footer_str = "#{template_prefix}= render 'shared/footer'#{template_postfix}\n"
      if options[:template_engine] == 'erb'
        insert_into_file 'app/views/layouts/application.html.erb', optimize_indentation(footer_str, 4), before: "  </body>\n"
      else
        append_to_file "app/views/layouts/application.html.#{options[:template_engine]}", optimize_indentation(footer_str, 4)
      end
    end

    # Skip a flash type if the key is a cookie/session timeone, since this can occure so regularly
    def update_application_helpers
      flash_str = <<~STR
        \n# remove any blank devise timeout errors
        flash.delete(:timedout)
      STR

      # User to prevent blank devise timeout error from flashing up
      insert_into_file 'app/helpers/application_helper.rb', "\n#{optimize_indentation(flash_str.strip, 4)}", after: "return '' unless flash.any?\n" if options[:framework] == 'bootstrap'

      # Make applicaction_helper immutable
      insert_into_file 'app/helpers/application_helper.rb', "# frozen_string_literal: true\n\n", before: "module ApplicationHelper\n"
    end

    private

    # Returns the application erb ruby tag prefix based on the views template_engine
    def template_prefix
      return '' unless options[:template_engine] == 'erb'

      '<%'
    end

    # Returns the application erb ruby tag postfix based on the views template_engine
    def template_postfix
      return '' unless options[:template_engine] == 'erb'

      ' %>'
    end

    # Check to see if the current application will be using erb or not
    def using_erb?
      options[:template_engine] == 'erb'
    end
  end
end
