module Exporters
  class YmlFormExporter

    def initialize(form_id, record_type='case', module_id='primeromodule-cp', opts={})
      if form_id.present?
        @form_id = form_id
      else
        @record_type = record_type
        @primero_module = PrimeroModule.get(module_id)
        if @primero_module.blank?
          Rails.logger.error {"YmlFormExporter: Invalid Module ID: #{module_id}"}
          raise ArgumentError.new("Invalid Module ID: #{module_id}")
        end
      end
      @export_dir_path = dir
      @show_hidden_forms = opts[:show_hidden_forms].present?
      @show_hidden_fields = opts[:show_hidden_fields].present?
      @locale = opts[:locale].present? ? opts[:locale] : FormSection::DEFAULT_BASE_LANGUAGE
    end

    def dir_name
      custom_export_dir = ENV['EXPORT_DIR']
      if custom_export_dir.present? && File.directory?(custom_export_dir)
        return custom_export_dir
      else
        name_ext = ''
        if @form_id.present?
          name_ext = @form_id
        else
          name_ext = "#{@record_type}_#{@primero_module.name.downcase}"
        end
        return File.join(Rails.root.join('tmp', 'exports'), "forms_yml_export_#{name_ext}_#{DateTime.now.strftime("%Y%m%d.%I%M%S")}")
      end
    end

    def dir
      FileUtils.mkdir_p dir_name
      dir_name
    end

    def yml_file_name(file_name='default')
      filename = File.join(@export_dir_path, "#{file_name}.yml")
    end

    def create_file_for_form(export_file=nil)
      Rails.logger.info {"Creating file #{export_file}.yml"}
      export_file_name = yml_file_name(export_file.to_s)
      @io = File.new(export_file_name, "w")
    end

    def complete
      @io.close if !@io.closed?
      return @io
    end

    def export_forms_to_yaml
      Rails.logger.info {"Begging of Forms YAML Exporter..."}
      Rails.logger.info {"Writing files to directory location: '#{@export_dir_path}"}
      @form_id.present? ? export_one_form : export_multiple_forms
    end

    def export_one_form
      fs = FormSection.by_unique_id(key: @form_id).first
      if fs.present?
        Rails.logger.info {"Form ID: #{@form_id}, Show Hidden Forms: #{@show_hidden_forms}, Show Hidden Fields: #{@show_hidden_fields}, Locale: #{@locale}"}
        export_form(fs)
      else
        Rails.logger.warn {"No FormSection found for #{@form_id}"}
      end
    end

    def export_multiple_forms
      forms = @primero_module.associated_forms_grouped_by_record_type(true)
      if forms.present?
        Rails.logger.info {"Record Type: #{@record_type}, Module: #{@primero_module.id}, Show Hidden Forms: #{@show_hidden_forms}, Show Hidden Fields: #{@show_hidden_fields}, Locale: #{@locale}"}
        forms_record_type = forms[@record_type]
        unless @show_hidden_forms
          visible_top_forms = forms_record_type.select{|f| f.visible? && !f.is_nested?}
          visible_subform_ids = visible_top_forms
                                    .map{|form| form.fields.map{|f| f.subform_section_id}}
                                    .flatten.compact
          visible_subforms = forms_record_type.select{|f| f.is_nested? && visible_subform_ids.include?(f.unique_id)}
          forms_record_type = visible_top_forms + visible_subforms
        end
        forms_record_type.each{|fs| export_form(fs)}
      else
        Rails.logger.warn {"No FormSections found for #{@primero_module.id}"}
      end
      export_lookups
    end

    def export_form(form_section)
      create_file_for_form(form_section.unique_id)
      form_hash = {}
      form_hash[form_section.unique_id] = form_section.localized_property_hash(@locale, @show_hidden_fields)
      file_hash = {}
      form_hash.compact
      file_hash[@locale] = form_hash.present? ? form_hash : nil
      @io << file_hash.to_yaml
      complete
    end

    def export_lookups
      Rails.logger.info {"Exporting Lookups..."}
      lookups = Lookup.all.all
      if lookups.present?
        Rails.logger.info {"Locale: #{@locale}"}
        create_file_for_form('lookups')
        lookup_hash = {}
        lookups.each {|lkp| lookup_hash[lkp.id] = lkp.localized_property_hash(@locale)}
        file_hash = {}
        file_hash[@locale] = lookup_hash
        @io << file_hash.to_yaml
        complete
      else
        Rails.logger.warn {'No Lookups found'}
      end
    end
  end
end
