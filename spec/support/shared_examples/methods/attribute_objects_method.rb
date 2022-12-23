# frozen_string_literal: true

# it_behaves_like "attribute_objects_method", %i[first_name last_name], Csvbuilder::Import::Attribute => 2
shared_examples "attribute_objects_method" do |column_names, cell_classes_to_count, method_name = :attribute_objects|
  subject { instance.public_send(method_name) }

  it "returns a hash of cells mapped to their column_name" do
    expect(subject.keys).to eql column_names
    expect(subject.values.map(&:class)).to eql(
      cell_classes_to_count.map do |cell_class, count|
        [cell_class] * count
      end.flatten
    )
  end

  it "is memoized" do
    expect(subject.object_id).to eql instance.public_send(method_name).object_id
  end
end
