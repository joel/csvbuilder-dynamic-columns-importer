# frozen_string_literal: true

require "spec_helper"

module Csvbuilder
  RSpec.describe Import do
    let(:klass) do
      Class.new do
        include Csvbuilder::Import
      end
    end

    it do
      expect(klass.included_modules).to include(Csvbuilder::Model::DynamicColumns)
    end
  end
end
