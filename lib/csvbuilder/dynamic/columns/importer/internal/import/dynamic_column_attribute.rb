# frozen_string_literal: true

require "csvbuilder/dynamic/columns/core/internal/dynamic_column_attribute_base"

module Csvbuilder
  module Import
    class DynamicColumnAttribute < Csvbuilder::DynamicColumnAttributeBase
      attr_reader :source_headers, :source_cells

      def initialize(column_name, source_headers, source_cells, row_model)
        @source_headers = source_headers
        @source_cells   = source_cells

        super(column_name, row_model)
      end

      def unformatted_value
        source_cells.zip(formatted_headers).map do |source_cell, formatted_header|
          call_process_cell(source_cell, formatted_header)
        end
      end

      def formatted_headers
        source_headers.map do |source_headers|
          row_model_class.format_dynamic_column_header(source_headers, column_name, row_model.context)
        end
      end

      class << self
        def define_process_cell(row_model_class, column_name)
          super { |formatted_cell, _source_headers| formatted_cell }
        end
      end
    end
  end
end
