class PollTemplateService
  def self.seed_database!
    id = 0
    YAML.load_file(Rails.root.join("config", "poll_templates.yml")).each_pair do |poll_type, config|
      PollTemplate.create(
        id: id += 1,
        name: I18n.t("poll_types.#{poll_type}"),
        poll_type: poll_type,
        chart_type: config['chart_type'],
        material_icon: config['material_icon'],
        poll_options: config['poll_options_attributes'].map {|a| a['name']},
        translate_option_name: config.fetch('translate_option_name', false),
        can_add_options: config.fetch('can_add_options', false),
        can_remove_options: config.fetch('can_remove_options', false),
        must_have_options: config.fetch('must_have_options', false),
        require_stance_choices: config.fetch('require_stance_choices', false),
        can_vote_anonymously: config.fetch('can_vote_anonymously', false),
        has_variable_score: config.fetch('has_variable_score', false),
        has_poll_options: config.fetch('has_poll_options', false),
        require_all_choices: config.fetch('require_all_choices', false),
        require_dots_per_person: config.fetch('required_custom_fields', []).include?('dots_per_person'),
        require_max_score: config.fetch('required_custom_fields', []).include?('max_score'),
        require_minimum_stance_choices: config.fetch('required_custom_fields', []).include?('minimum_stance_choices'),
        require_can_respond_maybe: config.fetch('required_custom_fields', []).include?('can_respond_maybe'),
        sort_options: config['sort_options']
      )
    end
  end
end
