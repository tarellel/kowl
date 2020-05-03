# frozen_string_literal: true

# for enabling versioning to verify event captioning
if defined?(PaperTrail)
  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_request = PaperTrail.request.enabled?
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.request.enabled = was_enabled_for_request
    end
  end
end
