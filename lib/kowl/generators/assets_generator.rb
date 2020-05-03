# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class AssetsGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'app', 'assets'), File.dirname(__FILE__))
    class_option :framework, type: :string, default: 'bootstrap', enum: %w[bootstrap semantic none]
    class_option :noauth, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean, default: false
    class_option :skip_mailer, type: :boolean, default: false
    class_option :skip_turbolinks, type: :boolean, default: false

    # If javascript is being used, this will setup jquery to be usable through webpack
    def setup_jquery_with_webpack
      return nil if options[:skip_javascript]

      add_package('jquery')
      append_to_file('app/javascript/packs/application.js', "\nrequire('jquery');\n")
      webpack_jquery_str = <<~JQUERY
        const webpack = require('webpack')
        environment.plugins.prepend('Provide',
          new webpack.ProvidePlugin({
            $: 'jquery/src/jquery',
            jQuery: 'jquery/src/jquery'
          })
        )
      JQUERY
      inject_into_file('config/webpack/environment.js', webpack_jquery_str, after: "const { environment } = require('@rails/webpacker')\n")
    end

    # This allows us to generate JS assets compressed with brotli and zopfil in production
    # Which dramatically reduces text based asset sizes
    # - https://github.com/tootsuite/mastodon/blob/master/config/webpack/production.js
    # - https://github.com/rails/webpacker/blob/9e671a3ebe368cfdc624309a9b4a55e998f87186/package/environments/production.js
    def setup_production_asset_compression
      return nil if options[:skip_javascript]

      # The compression-webpack-plugin package is included in @rails/webpacker.
      # => But this lets us easily access it from our webpacker config
      add_package('compression-webpack-plugin brotli-webpack-plugin @gfx/zopfli')
      webpack_plugins_str = <<~BROTLI
        // Compress the heck out of any static assets included by webpacker (using Brotlie)
        environment.plugins.append('BrotliCompression',
          new CompressionPlugin({
            filename: '[path].br[query]',
            algorithm: 'brotliCompress',
            test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
            compressionOptions: {
              level: 11
            },
            cache: true,
            threshold: 10240,
            minRatio: 0.8,
            deleteOriginalAssets: false,
          })
        )

        // Override default compression with Zopfli compression
        environment.plugins.append('Compression',
          new CompressionPlugin({
            filename: '[path].gz[query]',
            algorithm(input, compressionOptions, callback) {
              return zopfli.gzip(input, compressionOptions, callback);
            },
            cache: true,
            threshold: 8192,
            test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
          }),
        )
      BROTLI

      include_plugins_str = <<~PLUGINS
        const CompressionPlugin = require('compression-webpack-plugin'); // General webpacker library containing compression methods
        const zopfli = require('@gfx/zopfli'); // Zopfli is used to increase gzip compression ratio for gzip
      PLUGINS

      inject_into_file('config/webpack/production.js', "#{include_plugins_str}\n\n#{webpack_plugins_str}", after: "const environment = require('./environment')\n")
    end

    # Unless skipping javascript, this adds some basic linter packages to the webpacker dev environments
    def setup_js_linters
      return nil if options[:skip_javascript]

      add_package('eslint prettier prettierrc --dev')
    end

    # If the application will be using Bootstrap or SemanticUI, this includes their JS files in the javascript packs file
    def setup_framework_js
      return nil if options[:skip_javascript]

      if options[:framework] == 'bootstrap'
        add_package('bootstrap popper.js')
        js_str = <<~BOOTSTRAP
          require('bootstrap');
          require('popper.js');\n
        BOOTSTRAP
      elsif options[:framework] == 'semantic'
        # The version is used because code semantic-ui and fomantic-ui packages require you to build them with gulp
        # => This makes it easier to get started without a ton of additional setup
        copy_file('app/javascript/packs/semantic.js', 'app/javascript/packs/semantic.js')
        js_str = <<~SEMANTIC
          import Semantic from './semantic';
        SEMANTIC
      end
      append_to_file('app/javascript/packs/application.js', js_str) unless js_str.blank?
    end

    # Add Bootstrap/Semantic JS to the application.js file
    def add_framework_js_to_webpack
      return nil if options[:skip_javascript] || !%w[bootstrap semantic].include?(options[:framework])

      # If you prefere to pass skip_turbolinks, have JS load with jQuery on the page load
      js_load_str = if options[:skip_turbolinks]
                      '$(document).ready(function() {'
                    else
                      '$(document).on("turbolinks:load", function() {'
                    end

      if options[:framework] == 'bootstrap'
        framework_js = <<~BOOTSTRAPJS
          #{js_load_str}
            // This will dismiss any and all flash alerts after 3 seconds
            window.setTimeout(function() {
              $('.alert').fadeTo(1000, 0).slideUp(1000, function() {
                $(this).remove();
              });
            }, 3000);
          });
        BOOTSTRAPJS
      elsif options[:framework] == 'semantic'
        framework_js = <<~SEMANTICJS
          #{js_load_str}
            // Allow the user to close the flash messages
            $('.message .close')
              .on('click', function(){
                $(this).closest('.message').transition('fade');
            });

            // Automatically close flash messages after 3 seconds
            window.setTimeout(function() {
              $('.message').transition('fade');
            }, 3000);
          });
        SEMANTICJS
      end
      append_to_file('app/javascript/packs/application.js', framework_js) unless options[:skip_javascript]
    end

    # If using bootstrap or semsanitic this includes some additional SCSS files with the application
    def copy_stylesheets
      return nil unless %w[bootstrap semantic].include? options[:framework]

      # Remove old application stylesheets and replace with new ones
      remove_file 'app/assets/stylesheets/application.css'
      directory "stylesheets/#{options[:framework]}", 'app/assets/stylesheets', force: true
      remove_file 'app/assets/stylesheets/application-mailer.scss' if options[:skip_mailer]
    end

    # Adds known css files to css assets to precompile
    def add_assets_to_precompile
      add_to_assets('application.css')
      return nil if options[:noauth]

      add_to_assets('administrate/application.css')
    end

    # If using webpacker, this will generate it's JS webpacker files for the application
    def add_admin_webpacker_assets
      return nil if options[:noauth] || options[:skip_javascript]

      template('app/javascript/packs/administrate.js', 'app/javascript/packs/administrate.js')
      copy_file('app/javascript/administrate/index.js', 'app/javascript/administrate/index.js')

      template('app/javascript/administrate/components/date_time_picker.js.tt', 'app/javascript/administrate/components/date_time_picker.js')
      template('app/javascript/administrate/components/table.js.tt', 'app/javascript/administrate/components/table.js')
    end

    # If using webpacker allow CSS Extraction for CSS, SCSS, and SASS to work when compiling webpacker assets
    def enable_css_extraction
      return nil if options[:skip_javascript]

      replace_string_in_file('config/webpacker.yml', "[\s]?extract_css[\:][\s]?false[\s]?", ' extract_css: true') unless options[:skip_javascript]
    end
  end
end
