# frozen_string_literal: true

module Csvbuilder
  module Dynamic
    module Columns
      RSpec.describe Importer do
        it "has a version number" do
          expect(Csvbuilder::Dynamic::Columns::Importer::VERSION).not_to be_nil
        end
      end
    end
  end
end
