# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Kowl Helpers' do
  context 'template engine str' do
    it { expect(template_engine_gem_str('semantic')).to eq('semantic_ui') }
    it { expect(template_engine_gem_str).to eq('bootstrap') }
  end

  context 'highlight' do
    it { expect(highlight('')).to eq('') }
    # without string to split
    it { expect(highlight('asdf')).to eq("\e[32masdf\e[0m") }
    it { expect(highlight('asd=efg')).to eq("\e[32masd=\e[33mefg\e[0m") }
  end

  context 'dh (default highlight)' do
    it { expect(dh('foo')).to eq("\e[34mfoo\e[0m") }
    it { expect(dh()).to eq('') }
  end
end
