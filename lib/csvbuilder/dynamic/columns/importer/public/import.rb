# frozen_string_literal: true

require "csvbuilder/importer/public/import"

require "csvbuilder/dynamic/columns/importer/concerns/import/dynamic_columns"
Csvbuilder::Import.include(Csvbuilder::Import::DynamicColumns)
