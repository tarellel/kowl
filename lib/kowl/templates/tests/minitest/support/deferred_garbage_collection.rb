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
