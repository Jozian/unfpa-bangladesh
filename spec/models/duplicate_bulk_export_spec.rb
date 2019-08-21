require 'rails_helper'
require 'sunspot'

describe DuplicateBulkExport, search: true do
  before :each do
    Sunspot.remove_all(Child)
  end

  before do
    FormSection.all.all.each &:destroy

    @bulk_exporter = DuplicateBulkExport.new
    @bulk_exporter.record_type = "case"

    @form_section = create(:form_section,
      unique_id: 'test_form',
      fields: [
        build(:field, name: 'national_id_no', type: 'text_field', display_name: 'National ID No'),
        build(:field, name: 'case_id', type: 'text_field', display_name: 'Case Id'),
        build(:field, name: 'unhcr_individual_no', type: 'text_field', display_name: 'Unh No'),
        build(:field, name: 'child_name_last_first', type: 'text_field', display_name: 'Name'),
        build(:field, name: 'age', type: 'numeric_field', display_name: 'Age'),
        build(:field, name: 'family_count_no', type: 'numeric_field', display_name: 'Family No'),
      ]
    )

    @user = setup_user(form_sections: [@form_section], primero_module: {id: PrimeroModule::CP})

    Sunspot.setup(Child) do
      string 'national_id_no', as: :national_id_no_sci
    end

    Child.refresh_form_properties

    Child.all.all.each &:destroy
  end

  it "export cases with duplicate ids" do
    child1 = create(:child, national_id_no: "test1", age: 5)
    child2 = create(:child, national_id_no: "test1", age: 6)
    child3 = create(:child, national_id_no: "test2", age: 2)

    Sunspot.commit

    expected_output = [
      [" ", "MOHA ID DEPRECATED", "National ID No", "Case ID", "Progress ID", "Child Name", "Age", "Sex", "Family Size"],
      ["1", "test1", "test1", child1.case_id, nil, "#{child1.case_id}, Test Child", "5", "U", nil],
      ["2", "test1", "test1", child2.case_id, nil, "#{child2.case_id}, Test Child", "6", "U", nil]
    ]

    expect(export_csv).to eq(expected_output)
  end

  context "when no cases found" do
    it "exports headers" do
      expect(export_csv).to eq([[" ", "MOHA ID DEPRECATED", "National ID No", "Case ID", "Progress ID",
          "Child Name", "Age", "Sex", "Family Size"]])
    end
  end

  def export_csv
    exporter = Exporters::DuplicateIdCSVExporter.new()
    exported = @bulk_exporter.process_records_in_batches(10, 10, "national_id_no") do |records|
      exporter.export(records)
    end

    CSV.parse(exporter.buffer.string)
  end
end