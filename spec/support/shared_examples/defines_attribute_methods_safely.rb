# frozen_string_literal: true

shared_examples "defines_attributes_methods_safely" do |attributes, mod = described_class|
  subject { instance.attributes }

  let(:row_model_class) do
    Class.new do
      include Csvbuilder::Model
      column :alpha
      inner_mod = mod.to_s.deconstantize # Csvbuilder::Import for constructor
      include "#{inner_mod}::Base".constantize if inner_mod.present?
      include mod
      column :beta
    end
  end

  it "#attributes works" do
    expect(subject).to eql attributes
  end
end
