[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

[![Kowl][rubygems-downloads]][rubygems-link]
[![Gem Version][rubygems-version]][rubygems-link]

<br />
<p align="center">
  <a href="https://github.com/tarellel/kowl">
    <img src="docs/images/cover.png" alt="Kowl Header Image">
  </a>
  <h3 align="center">Kowl (Ruby gem)</h3>
  <p align="center">
    Kowl is a Rails <em>(v6.*)</em> based <em>opinionated</em> application generator used to get started quick. It's purpose is so you can focus on building your application rather spending days setting up the basic gems every time.
    <br /><br />
    · <a href="https://github.com/tarellel/kowl/issues">Report Bug</a>
    · <a href="https://github.com/tarellel/kowl/issues">Request Feature</a>
  </p>
</p>

## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Gems](#gems)
* [Notes](#notes)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)

## About The Project

Kowl is tool to easily generate a Rails (~> 6) application with a number of configurations, templates, and generators applied.
That way your're not spending days running through gems and documentation to get an application setup.
(This can include setting up bootstrap, devise, sidekiq, linters, dockerizing your application, and various other steps)

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Requires a minimum of:

* `Ruby >= 2.5`
* `Rails >= 2.6`

```shell
# If using RVM
rvm install 2.6.5
rvm use 2.6.5 --default
```

### Installation

**1.** Install the required dependencies

Depending on the options you want to use when generating an application your dependencies will vary.

* `autogen autoconf cmake libtool make v8` - For nokogiri, sassc, and various C based ruby gems.
* `docker` - If you want to build a docker image using the application specific generated Dockerfile.
* `git` - Is generally required for installing rubygems anyways.
* `graphviz` - For generating an applications [ERD](https://github.com/voormedia/rails-erd) (unless you skip generating an ERD for your application `--skip_erd`)
* `jemalloc` - _**Optional**_, but helps with improving rubies memory allocation. (If using RVM you can install a ruby version to utilize jemalloc using: `rvm install 2.6.5 -C --with-jemalloc`)
* `imagemagick` - If you plan on using ActionText/Trix you'll want `imagemagick` or `vips` for processing image uploads
* `libsodium` - If you wish to encrypt particular PII user attributes (using the [lockbox gem](https://github.com/ankane/lockbox) by generating an application with the encrypt flag `--encrypt`)
* `node && yarn` - Generally any new rails app requires node and yarn for installing and transpiling JS dependencies.

Dependant on the database your application will be using, you'll also need to install their required C adapters

* PostgreSQL - `postgresql`
* Oracle - `instantclient-basic && instantclient-sdk`

  ```shell
  brew update
  brew tap InstantClientTap/instantclient

  brew install instantclient-basic instantclient-sdk
  ```

* SQLserver - `freetds`

**2.** Install ruby gem

```bash
gem install kowl
```

## Usage

```shell
Usage:
  kowl AppName

Options:
-d [--database=DATABASE]                     # If you want to use a specific database for the application (builds with sqlite3 until you are ready)
                                             # Default: sqlite3
   [--docker_distro=DISTRO]                  # Specify what docker distro to use for the application (alpine, debian)
                                             # Default: alpine (If you specify to use Oracle your distro will default to Debian)
   [--encrypt]                               # If you want encrypt various user data (using lockbox)? (For GDPR compliance)
                                             # Default: false (This requires you to install libsodium in order to encrypt the user data)
   [--framework=CSSFRAMEWORK]                # If you want to generate views using a specific CSS framework (bootstrap, semantic, none)
                                             # Default: bootstrap
   [--git_repo=REPO_NAME]                    # If you've already created a gitlab repo, specify the repo and and it will be added.
                                             # ie: https://github/username/REPO_NAME.git
                                             # Default: nil
   [--mailer=MAILER]                         # Which transactional mailer you want to use in production (postmark or sparkpost)?
                                             # Default: sparkpost (unless you specify to --skip_mailer, than neither will be used)
   [--noauth]                                # If you would like to skip adding devise and pundit to the application
                                             # Default: false
   [--simpleform]                            # Do you want your application to use simpleform to generate forms
                                             # Default: false
   [--skip_docker]                           # If you want your application to skip generating any docker files (Dockerfile, docker-compose.yml, and .dockerignore)
                                             # Default: false
   [--skip_erd]                              # If you want to skip generating an ERD for your application (requires graphviz to be installed)
                                             # Default: false
-G [--skip_git]                              # Do you want the generator to skip creating initializing and commit files to git
                                             # Default: false
   [--skip_javascript]                       # Skip adding javascript (webpacker) to the application
                                             # Default: false
   [--skip_mailer]                           # Do you want to skip setting up a
                                             # Default: false
   [--skip_pagination]                       # Do you want to skip using pagination with your application?
                                             # Default: false
   [--skip_pry]                              # Do you want to skip using pry with your applications rails console?
                                             # Default: false
   [--skip_sidekiq]                          # Do you want to skip setting up sidekiq (for background jobs, mailers, etc.)
                                             # Default: false
   [--skip_spring]                           # If you hate spring and want to skip using it with your application.
                                             # Default: false
-T [--skip_tests]                            # Do you want your application to skip building with tests
                                             # Default: false
   [--skip_turbolinks]                       # If you want to skip adding turbolinks to your applications assets
                                             # Default: false
   [--template_engine=ENGINE]                # Assign a template_engine to use for the applications views (erb, slim, haml)
                                             # Default: erb
   [--test_engine=TEST_ENGINE]               # If you want to generate the application using a specific test suite (minitest, RSpec, none)
                                             # Default: rspec
   [--uuid]                                  # Enable setting as database primary keys as UUIDs (Only while using PostgreSQL)
                                             # Default: false (NOTE: This feature is still under development)
-W [--webpack=JSFRAMEWORK]                   # If you want initialize to webpacker with a specific JS framework (react vue angular elm stimulus)
                                             # Default: nil
```

**Examples:**

  `kowl AppName`

  Generate an application using sqlite3, with a name of "AppName", requiring authentication, using RSpec, and using bootstrap.

  `kowl AppName --database=oracle --simpleform --noauth`

  This will generate an application using the Oracle database, using simple_form, and not requiring any sort of authentication (anyone can hit this app.)

  `kowl AppName --simpleform --template_engine=slim`

  This will generate an application defaulting to sqlite3, using simple_form, the Slim template engine, with pagination, and requiring authentication to load the application.

  `kowl AppName --simpleform --template_engine=slim --skip_tests`

  Generate an application using sqlite3, using bootstrap CSS framework, using the slim template engine, and build without any tests.

  `kowl AppName --git_repo=https://github/username/REPO_NAME.git`

  Will generate an app with the remote repo set as `https://github/username/REPO_NAME.git`

  `kowl foobar --template_engine=haml --simpleform --framework=semantic;`

  This will generating an app with the HAML template engine, using simpleform, and using the Semantic UI CSS Framework

### Walk-Throughts

* [#](/docs/actiontext.md) Create an application using simple_form and create posts scaffold and admin page that will use ActionText 

## Gems

The gems included in the applications Gemfile are dependant on options passed when generating an application.

#### Assets

* [autoprefixer-rails](https://github.com/ai/autoprefixer-rails) parse CSS and add vendor prefixes to CSS rules using values from the Can I Use database
* [font-awesome-sass](https://github.com/FortAwesome/font-awesome-sass) for including fontawesome in your applications CSS.
* [sass-rails](https://github.com/rails/sass-rails) integration for Ruby on Rails projects with the Sass stylesheet language
* Dependant on the framework specified, these gems will be used to generate scaffold, devise, and layout views.
  * [bootstrap_views_generator](https://github.com/tarellel/bootstrap_views_generator) for generating [Bootstrap](https://getbootstrap.com/) based scaffold views, devise views, and layouts _.(also dependant on if you want to use pagination, simple_form, and/or what template engine you use)_.
  * [semantic_ui_views_generator](https://github.com/tarellel/semantic_ui_views_generator) for generating [SemanticUI](https://semantic-ui.com/) based scaffold views, devise views, and layouts _.(also dependant on if you want to use pagination, simple_form, and/or what template engine you use)_.

#### Database gems

These gems are in addition to your applications required database adapters

* [bullet](https://github.com/flyerhzm/bullet) help to hunt down and catch N+1 queries throughout the application.
* [rails_erd](https://github.com/voormedia/rails-erd) used to generate Entity-Relationship Diagrams for Rails applications.
* [strong_migrations](https://github.com/ankane/strong_migrations) used to catch unsafe migrations in development
* If the application is generated to use postgresql as it's database.
  * [pghero](https://github.com/ankane/pghero) a dashboard for monitor application query performance.
  * [pg_query](https://github.com/lfittl/pg_query) allows you to normalize queries and parse these normalized queries.

#### Devise/Users

User gems that will be included unless the `--noauth` flag is specified when generating an application.

* [Argon2](https://github.com/technion/ruby-argon2) will be used for devise as as the devise encryption method _([based on Ankane's recommendations](https://ankane.org/devise-argon2))_
* [AuthTrail](https://github.com/ankane/authtrail) used to track Devise login activity.
* [Devise](https://github.com/heartcombo/devise) a flexible authentication solution build with rails in mind.
* [Devise-Security](https://github.com/devise-security/devise-security) used to enforce better security measures with devise.
* [MaxmindDB](https://github.com/yhirose/maxminddb) used for add getting GeoLocation details for the applications AuthTrail entries. The simplest and cheapest method to download the [GeoLite2](https://dev.maxmind.com/geoip/geoip2/geolite2/) database. _(MaxMind now requires you to login to download the geolocation database)_ Uncompress and put the geolocation database in `db/maxmind`.
* [Pretender](https://github.com/ankane/pretender) to login as another use with devise _(helps when developing various rolls and permissions)_.
* [Pundit](https://github.com/varvet/pundit) an authorization system build off a basic OOP pattern.
* [valid_email2](https://github.com/micke/valid_email2) an email validation library.

#### Mailers

* [bootstrap-email](https://bootstrapemail.com/) for cleaning up and formatting emails with bootstrap syntax (responsive and clean).
* [letter_opener](https://github.com/ryanb/letter_opener) to preview outgoing mails in your rails application.
* [letter_opener_web](https://github.com/fgrehm/letter_opener_web) a web interface for browsing all outbound emails.
* Dependant on the mailer you specified
  * [postmark-rails](https://github.com/wildbit/postmark-rails) for sending transactional emails with [postmark](https://postmarkapp.com/).
  * [sparkpost_rails](https://github.com/the-refinery/sparkpost_rails) for sending transactional emails with [sparkpost](https://www.sparkpost.com/).

#### Misc

* [active_decorator](https://github.com/amatsuda/active_decorator) OOP view helpers for cleaning up your models.
* [annotate](https://github.com/ctran/annotate_models) for adding a comment summarizing the current schema to models, routes, etc.
* [auto_strip_attributes](https://github.com/holli/auto_strip_attributes) remove unnecessary whitespace from ActiveRecord attributes.
* [fast_jsonapi](fast-jsonapi/fast_jsonapi) lightning fast JSON:API serializer (originally releases by [Netflix](https://github.com/Netflix/fast_jsonapi))
* [meta-tags](https://github.com/kpumuk/meta-tags) helpers for making SEO/meta-tags easier to manage with your rails application.
* [oj](http://www.ohler.com/oj/) a fast JSON object serializer.
* [simple_form](https://github.com/heartcombo/simple_form) a DSL for making forms easy to style and manage.
* [pagy](https://github.com/ddnexus/pagy) for lightening fast and easy to use pagination.
* Dependant on the `--template_engine` specified when generating an application.
  * [haml-rails](https://github.com/haml/haml-rails) enables the [HAML](http://haml.info/) templaing engine and generators with your rails application.
  * [slim-rails](https://github.com/slim-template/slim-rails) enables the [SLIM](http://slim-lang.com/) templating engine and generators with your rails application.
* [pry](https://github.com/pry/pry) a powerful IRB alternative.
* [pry-rails](https://github.com/rweng/pry-rails) a adapter to make it easy to use pry with a rails application.
* [spirit_hands](https://github.com/steakknife/spirit_hands) a opinionated console adapter for cleaning up your application output.


#### Performance

* [attendance](https://github.com/schneems/attendance) change the behavior of `present?` to prevent unnecessary SQL queries.
* [fast_blank](https://github.com/SamSaffron/fast_blank) a C extension which provides a fast implementation of Active Support's `String#blank?`.

#### Responses, Errors, and Security

* [dotenv-rails](https://github.com/bkeepers/dotenv) to enable loading of environment variables with `.env` files.
* [Rack-attack](https://github.com/kickstarter/rack-attack) Rack middleware for blocking & throttling
* [Slowpoke](https://github.com/ankane/slowpoke) timeout long running page requests.

#### Security and Logging

* [blind_index](https://github.com/ankane/blind_index) for search encrypted database fields.
* [lockbox](https://github.com/ankane/lockbox) for encrypting database fields when at rest.
* [rbnacl](https://github.com/RubyCrypto/rbnacl) a ruby adapter to enable using using libsodium (NaCl) for encryption.
* Logging
  * [lograge](https://github.com/roidrage/lograge) is used to cleanup and tame Rails logs.
  * [logstop](https://github.com/ankane/logstop) for filtering out a list of basic PII/PHI attributes from Application logs.

#### Sidekiq and Background Jobs

These gems will be included to setup sidekiq unless the `--skip_sidekiq` flag is used when generating an application.

* [hiredis](https://github.com/redis/hiredis-rb) a C adapter for connecting your application to a Redis datestore _(faster than the ruby redis library)_.
* [Sidekiq](https://github.com/mperham/sidekiq/) simple, efficient background processing for Ruby
* [Sidekiq-Failures](https://github.com/mhfs/sidekiq-failures/) to get a better view of what jobs are failing.
* [Sidekiq-Scheduler](https://moove-it.github.io/sidekiq-scheduler/) to schedule sidekiq jobs on a given interval.
* [Sidekiq-Status](https://github.com/utgarda/sidekiq-status) is sidekiq extension to get a better status report of all currently running jobs.

#### Linter gems included

* [brakeman](https://brakemanscanner.org/) a static code analyser to detect possible ruby/rails vulnerabilities.
* [bundler-audit](https://github.com/rubysec/bundler-audit) used to check andd verify if any of the applications gems have known updates/vulnerabilities.
* [rails_best_practices](https://github.com/flyerhzm/rails_best_practices) a code metric tool to check the quality of Rails code.
* Rubocop
  * [rubocop](https://github.com/rubocop-hq/rubocop/) A Ruby static code analyzer and formatter based of the [Ruby style guide](https://rubystyle.guide/).
  * [rubocop-performance](https://github.com/rubocop-hq/rubocop-performance/) an extension of RuboCop focused on code performance checks.
  * [rubocop-rails](https://github.com/rubocop-hq/rubocop-rails/) a RuboCop extension focused on enforcing Rails best practices and coding conventions.
  * Dependant on the test_engine you specified to use when generating the application
    * [rubocop-minitest](https://github.com/rubocop-hq/rubocop-minitest) a Rubocop extension focused on enforcing Minitest best practices and coding conventions
    * [rubocop-rspec](https://github.com/rubocop-hq/rubocop-rspec) a Rubocop extension focused on enforcing Rspec best practices.
* [scss_lint](https://github.com/sds/scss-lint) is linter to help you keep your SCSS/SASS clean and readable.
* [rubycritic](https://github.com/whitesmith/rubycritic) a Ruby code quality reporter.
* Dependant on the template engine you specified to use
  * [erb_lint](https://github.com/Shopify/erb-lint) a linter to validate you're writing clean and valid erbs views
  * [haml_lint](https://github.com/sds/haml-lint) a linter to validate you're writing clean and valid haml views
  * [slim_lint](https://github.com/sds/slim-lint) a linter to validate you're writing clean and valid slims views

#### Test gems included _(dependant on test_engine used)_

* [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) for flushing databases as you run tests
* [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails) a fixtures replacement for generating sample data with tests.
* [faker](https://github.com/faker-ruby/faker) for generating sample data for your appliaction or tests.
* [rails-controller-testing](https://github.com/rails/rails-controller-testing) added to add additional methods for controller integration tests.
* [shoulda](https://github.com/thoughtbot/shoulda) helps you write understandable, maintainable Rails-specific tests. _(also contains [shoulda-matchers](https://matchers.shoulda.io/) and [should-context](https://github.com/thoughtbot/shoulda-context))_
* [simplecov](https://github.com/colszowka/simplecovs) for generating a code coverage report when running tests.
* [test-prof](https://test-prof.evilmartians.io/#/) helps with application test profiling and performance stats.
* [timecop](https://github.com/travisjeffery/timecop) used to run time bases tests across your application
* Integration Testing
  - [capybara](https://github.com/teamcapybara/capybara) a test framework to make building integration tests easy to get started with.
  - [selenium-webdriver](https://github.com/SeleniumHQ/selenium) a webdriver to make running selenium based tests easier to build.
  - [webdrivers](https://github.com/titusfortner/webdrivers) used to selenium based tests against your application to simulaet actual user requests.

##### MiniTest

* [minitest](https://github.com/seattlerb/minitest) a complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking.
* [minitest-reporters](https://github.com/kern/minitest-reporters) customizable output for minitest results.

##### Rspec

* [formulaic](https://github.com/thoughtbot/formulaic) allows you to perform easier form testing with Capybara
* [fuubar](https://github.com/thekompanee/fuubar) a progressbar to display when running rspec tests.
* [pig-ci-rails](https://github.com/PigCI/pig-ci-rails) For displaying application memory metrics while running tests
* [pundit-matchers](https://github.com/chrisalley/pundit-matchers) matchers for testing Pundit authorisation policies. _(unless you generate your app with `--noauth`)_
* [rspec-rails](https://github.com/rspec/rspec-rails) easily include rspec with a rails application.
* [rspec-sidekiq](https://github.com/philostler/rspec-sidekiq) a collection of methods to assist with create tests for Sidekiq workers _(unless you specific to `--skip_sidekiq`)_

If using ruby `>= 2.7` it also includes `e2mmap` and `thwait` to prevent ruby dependency errors.

## Additonal Stuff

* It corrects the issue ([37008](https://github.com/rails/rails/pull/37008)) when generating a Rails (v6) application when specifying Oracle as the database
* When using this gem to generate applications it changes the devise password encrypting from bcrypt to [Argon2](https://cryptobook.nakov.com/mac-and-key-derivation/argon2)
* When generating application Dockerfiles it defaults to using [Alpine](https://alpinelinux.org/) which will produce smaller docker images. But if applications are specified to use Oracle as the database it will default to [Debian](https://www.debian.org/) _(due to the required dependencies to use the [Oracle InstantClient](https://www.oracle.com/database/technologies/instant-client.html))_.
* The `--encrypt` flag is used to enforce [GDPR](https://gdprchecklist.io/) and [CCPA](https://oag.ca.gov/privacy/ccpa) compliance to encrypt PII for users. _([GDPR Article 34, Section 3 (a)](https://gdpr-info.eu/art-34-gdpr/))_ By encrypting user identifiable information; this ensurers PII isn't plain text readable by hackers in case there is a data breach with the application. When encrypting user data it will use the [lockbox](https://github.com/ankane/lockbox) with the [xsalsa20](https://en.wikipedia.org/wiki/Salsa20) algorithm which requires [libsodium](https://libsodium.gitbook.io/doc/).
* When using javascript/webpacker not only will it gzip js assets, it will also compress assets with brotli and zopfli compression _(in production)_.
* A number of linter dotfiles added, that way you don't have to hunt down how they are setup. And you only need to use the linters than you want to use.

## Notes

* If looking to build a secure rails application I would begin by reading Ankane's article [Securing Sensitive Data in Rails](https://ankane.org/sensitive-data-rails) for some basic for rails security best practices.


## Roadmap

See the [open issues](https://github.com/tarellel/kowl/issues) for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Brandon Hicks ([@tarellel](https://twitter.com/tarellel))

Project Link: [https://github.com/tarellel/kowl](https://github.com/tarellel/kowl)

## Acknowledgements

* [@ankane](https://github.com/ankane) - For various rails related security [recommendations](https://ankane.org/sensitive-data-rails)

[contributors-shield]: https://img.shields.io/github/contributors/tarellel/kowl.svg?style=flat-square
[contributors-url]: https://github.com/tarellel/kowl/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/tarellel/kowl.svg?style=flat-square
[forks-url]: https://github.com/tarellel/kowl/network/members
[stars-shield]: https://img.shields.io/github/stars/tarellel/kowl.svg?style=flat-square
[stars-url]: https://github.com/tarellel/kowl/stargazers
[issues-shield]: https://img.shields.io/github/issues/tarellel/kowl.svg?style=flat-square
[issues-url]: https://github.com/tarellel/kowl/issues
[license-shield]: https://img.shields.io/github/license/tarellel/kowl.svg?style=flat-square
[license-url]: https://github.com/tarellel/kowl/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[product-screenshot]: docs/images/cover.png

[rubygems-downloads]: https://ruby-gem-downloads-badge.herokuapp.com/kowl?type=total
[rubygems-link]: https://rubygems.org/gems/kowl
[rubygems-version]: https://badge.fury.io/rb/kowl.svg
