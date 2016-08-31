transitions_subform = [
    Field.new({"name" => "type",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Type",
              }),
    Field.new({"name" => "to_user_local",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Local User",
              }),
    Field.new({"name" => "to_user_remote",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Remote User",
              }),
    Field.new({"name" => "to_user_local_status",
               "type" => "select_box",
               "editable" => false,
               "display_name_all" => "Status",
               "option_strings_text_all" =>
                   ["Pending",
                    "Accepted",
                    "Rejected"
                   ].join("\n")
              }),
    Field.new({"name" => "to_user_agency",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Remote User Agency",
              }),
    Field.new({"name" => "notes",
               "type" => "textarea",
               "editable"=>false,
               "display_name_all" => "Notes",
              }),
    Field.new({"name" => "transitioned_by",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Transferred or Referred By",
              }),
    Field.new({"name" => "service",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "Service",
              }),
    Field.new({"name" => "is_remote",
               "type" => "tick_box",
               "tick_box_label_all" => "Yes",
               "editable"=>false,
               "display_name_all" => "Is the referral or transfer to a remote system?",
              }),
    Field.new({"name" => "type_of_export",
               "type" => "text_field",
               "editable"=>false,
               "display_name_all" => "What type of export do you want",
              }),
    Field.new({"name" => "consent_overridden",
               "type" => "tick_box",
               "tick_box_label_all" => "Yes",
               "editable"=>false,
               "display_name_all" => "No Consent to Share Setting Overridden",
              }),
    Field.new({"name" => "created_at",
               "type" => "date_field",
               "editable"=>false,
               "display_name_all" => "Date of referral or transfer",
              }),
]

transitions = FormSection.create_or_update_form_section({
     "visible"=>false,
     "is_nested"=>true,
     :order_form_group => 150,
     :order => 10,
     :order_subform => 1,
     :unique_id=>"transitions",
     :parent_form=>"case",
     "editable"=>false,
     :fields => transitions_subform,
     "name_all" => "Nested Transitions Subform",
     "description_all" => "Transitions Subform",
     "collapsed_fields" => ["type", "service", "to_user_local", "to_user_remote", "created_at"]
})

referral_transfer_fields = [
  Field.new({"name" => "transitions",
             "type" => "subform",
             "editable" => false,
             "subform_section_id" => transitions.unique_id,
             "display_name_all" => "Transfers and Referrals",
             "subform_sort_by" => "created_at"
            })
]

FormSection.create_or_update_form_section({
  :unique_id=>"referral_transfer",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 150,
  :order => 10,
  :order_subform => 0,
  :form_group_name => "Referrals and Transfers",
  "editable" => false,
  :fields => referral_transfer_fields,
  :is_first_tab => true,
  "name_all" => "Referrals and Transfers",
  "description_all" => "List of Transfers and Referrals"
})