# frozen_string_literal: true

require "spec_helper"

module Csvbuilder
  module Import
    dynamic_column_source_headers = %w[Ruby Python Java Rust Javascript GoLand]
    dynamic_column_source_cells = %w[Yes Yes No Yes Yes No]
    RSpec.describe DynamicColumns do
      let(:row_model_class) do
        Class.new do
          include Csvbuilder::Model
          include Csvbuilder::Import
          dynamic_column :skills
        end
      end

      let(:instance)   { row_model_class.new(source_row, source_headers: headers) }
      let(:headers)    { dynamic_column_source_headers }
      let(:source_row) { dynamic_column_source_cells }

      shared_context "standard columns defined" do
        let(:row_model_class) { DynamicColumnImportModel }
        let(:headers)    { %w[first_name last_name] + dynamic_column_source_headers }
        let(:source_row) { %w[Mario Italian] + dynamic_column_source_cells }
      end

      describe "instance" do
        describe "#dynamic_Column_attribute_objects" do
          with_this_then_context "standard columns defined" do
            it_behaves_like "attribute_objects_method",
                            %i[skills],
                            { Csvbuilder::Import::DynamicColumnAttribute => 1 },
                            :dynamic_column_attribute_objects
          end
        end

        describe "#formatted_dynamic_column_headers" do
          subject(:formatted_dynamic_column_headers) { instance.formatted_dynamic_column_headers }

          let(:row_model_class) do
            Class.new(super()) do
              def self.format_dynamic_column_header(*args)
                args.join("__")
              end
            end
          end

          it "returns the formatted_headers" do
            expect(formatted_dynamic_column_headers).to eql(
              [
                "Ruby__skills__#<OpenStruct>",
                "Python__skills__#<OpenStruct>",
                "Java__skills__#<OpenStruct>",
                "Rust__skills__#<OpenStruct>",
                "Javascript__skills__#<OpenStruct>",
                "GoLand__skills__#<OpenStruct>"
              ]
            )
          end
        end

        describe "#dynamic_column_source_headers" do
          it("calls the class method") {
            expect(row_model_class).to receive(:dynamic_column_source_headers).with(headers)
            instance.dynamic_column_source_headers
          }
        end

        describe "#dynamic_column_source_cells" do
          it("calls the class method") {
            expect(row_model_class).to receive(:dynamic_column_source_cells).with(source_row)
            instance.dynamic_column_source_cells
          }
        end
      end

      describe "class" do
        describe "::dynamic_column_source_headers" do
          subject(:source_headers) { row_model_class.dynamic_column_source_headers headers }

          with_this_then_context "standard columns defined" do
            it "returns the dynamic part of the headers" do
              expect(source_headers).to eql dynamic_column_source_headers
            end

            context "with no dynamic classes" do
              let(:row_model_class) { BasicImportModel }

              it "returns empty array" do
                expect(source_headers).to eql []
              end
            end
          end
        end

        describe "::dynamic_column_source_cells" do
          subject(:source_cells) { row_model_class.dynamic_column_source_cells source_row }

          with_this_then_context "standard columns defined" do
            it "returns the dynamic part of source row" do
              expect(source_cells).to eql dynamic_column_source_cells
            end

            context "with no dynamic classes" do
              let(:row_model_class) { BasicImportModel }

              it "returns empty array" do
                expect(source_cells).to eql []
              end
            end
          end
        end

        describe "::dynamic_column" do
          it_behaves_like "dynamic_column_method", Import, dynamic_column_source_cells
        end

        describe "::define_dynamic_attribute_method" do
          subject(:define_dynamic_attribute_method) { row_model_class.send(:define_dynamic_attribute_method, :skills) }

          it "makes an attribute that calls original_attribute" do
            define_dynamic_attribute_method
            expect(instance).to receive(:original_attribute).with(:skills).and_return("tested")
            expect(instance.skills).to eql "tested"
          end
        end
      end
    end
  end
end
