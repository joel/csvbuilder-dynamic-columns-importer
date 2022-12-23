# frozen_string_literal: true

require "spec_helper"

module Csvbuilder
  module Import
    RSpec.describe DynamicColumnAttribute do
      describe "instance" do
        let(:instance) { described_class.new(:skills, source_headers, source_cells, row_model) }

        let(:source_headers) { %w[Ruby Python Java Rust Javascript GoLand] }
        let(:source_cells) { %w[Yes Yes No Yes Yes No] }
        let(:row_model_class) do
          Class.new do
            include Csvbuilder::Model
            include Csvbuilder::Import
            dynamic_column :skills
          end
        end
        let(:row_model) { row_model_class.new }

        it_behaves_like "has_needed_value_methods", Csvbuilder::DynamicColumnsBase

        describe "#unformatted_value" do
          subject(:unformatted_value) { instance.unformatted_value }

          it "returns an array of the formatted_cell" do
            expect(instance).to receive(:formatted_cells).and_call_original
            expect(instance).to receive(:formatted_headers).and_call_original

            expect(unformatted_value).to eql source_cells
          end

          context "with process method defined" do
            before do
              row_model_class.class_eval do
                def skill(formatted_cell, source_headers)
                  "#{formatted_cell}__#{source_headers}"
                end
              end
            end

            it "return an array of the result of the process method" do
              expect(unformatted_value).to eql(
                %w[
                  Yes__Ruby
                  Yes__Python
                  No__Java
                  Yes__Rust
                  Yes__Javascript
                  No__GoLand
                ]
              )
            end
          end
        end

        describe "#formatted_cells" do
          it_behaves_like "formatted_cells_method", Csvbuilder::Import, [
            "Yes__skills__#<OpenStruct>",
            "Yes__skills__#<OpenStruct>",
            "No__skills__#<OpenStruct>",
            "Yes__skills__#<OpenStruct>",
            "Yes__skills__#<OpenStruct>",
            "No__skills__#<OpenStruct>"
          ]
        end

        describe "#formatted_headers" do
          subject(:formatted_headers) { instance.formatted_headers }

          before do
            row_model_class.class_eval do
              def self.format_dynamic_column_header(*args)
                args.join("__")
              end
            end
          end

          it "returns an array of the formatted_cells" do
            expect(formatted_headers).to eql [
              "Ruby__skills__#<OpenStruct>",
              "Python__skills__#<OpenStruct>",
              "Java__skills__#<OpenStruct>",
              "Rust__skills__#<OpenStruct>",
              "Javascript__skills__#<OpenStruct>",
              "GoLand__skills__#<OpenStruct>"
            ]
          end

          context "with regular column defined" do
            let(:row_model_class) do
              Class.new do
                include Csvbuilder::Model
                include Csvbuilder::Import
                column :alpha
                dynamic_column :skills
              end
            end

            it "bumps the index up for the dynamic_column_index" do
              expect(formatted_headers.first).to eql "Ruby__skills__#<OpenStruct>"
            end
          end
        end
      end

      describe "class" do
        describe "::define_process_cell" do
          subject(:define_process_cell) { described_class.define_process_cell(klass, :somethings) }

          let(:klass) { Class.new { include Csvbuilder::Proxy } }

          it "adds the process method to the class" do
            define_process_cell
            expect(klass.new.something("a", "b")).to eql "a"
          end
        end
      end
    end
  end
end
