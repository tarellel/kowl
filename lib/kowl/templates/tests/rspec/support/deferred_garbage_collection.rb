# frozen_string_literal: true

# https://stackoverflow.com/questions/10937366/find-a-list-of-slow-rspec-tests
# https://makandracards.com/makandra/950-speed-up-rspec-by-deferring-garbage-collection
class DeferredGarbageCollection
  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 10.0).to_f
  @@last_gc_run = Time.now

  def self.start
    GC.disable if DEFERRED_GC_THRESHOLD.positive?
  end

  def self.reconsider
    return unless DEFERRED_GC_THRESHOLD.positive? && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD

    GC.enable
    GC.start
    GC.disable
    @@last_gc_run = Time.now
  end
end

# turn off garbage collection when running tests, place this in spec_helper.rb
RSpec.configure do |config|
  config.before(:all) do
    DeferredGarbageCollection.start
  end

  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
end
