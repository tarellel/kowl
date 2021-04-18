# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.7] - 2021-04-17

* Update Rails version to account for mimemagic dependency issue
* Convert a batch of of requires to require_relative (minor performance gain)

## [0.0.6] - 2020-11-27

* Correct older administrate config causing entire generator to fail
* Correct User Polymorphic association with administrate dashboard

## [0.0.5]

* Correct issue with compile assets path in staging
* Update FreeTDS version used by for SQLserver connections in the docker container
* Added minimum python packages to containers for Brotli and Zopfli asset compression (required by js packages)

## [0.0.4] - 2020-07-04

* Added fasterer to test for slow code
* Updated base Rails application version

## [0.0.3] - 2020-06-27

Corrected issue with fast_jsonapi fork being renamed to jsonapi-serializer

## [0.0.2] - 2020-05-03

Added tests, updated readme/gemspecs, and version bump to update rubygems page

## [0.0.1] - 2020-05-02

### Added

- Initial Setup
