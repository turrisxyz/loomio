class AddPollTemplatesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_templates do |t|
      t.string :name, null: false
      t.string :poll_type, null: false
      t.string :chart_type, null: false
      t.string :material_icon, null: false, default: 'mdi-thumbs-up-down'
      t.integer :group_id, null: true
      t.string :poll_options, array: true, null: false, default: []
      t.boolean :translate_option_name, null: false, default: false
      t.boolean :can_add_options, null: false, default: false
      t.boolean :can_remove_options, null: false, default: false
      t.boolean :must_have_options, null: false, default: false
      t.boolean :require_stance_choices, null: false, default: false
      t.boolean :can_vote_anonymously, null: false, default: false
      t.boolean :has_variable_score, null: false, default: false
      t.boolean :has_option_score_counts, null: false, default: false
      t.boolean :has_option_icons, null: false, default: false
      t.boolean :dates_as_options, null: false, default: false
      t.boolean :has_poll_options, null: false, default: false
      t.boolean :require_all_choices, null: false, default: false
      t.boolean :require_dots_per_person, null: false, default: false
      t.boolean :require_max_score, null: false, default: false
      t.boolean :require_minimum_stance_choices, null: false, default: false
      t.boolean :require_can_respond_maybe, null: false, default: false
      t.string :sort_options, array: true, default: ['newest_first', 'oldest_first', 'undecided_first'], null: false
      t.timestamps
    end
    add_index :poll_templates, :group_id
    PollTemplateService.seed_database!
  end
end
