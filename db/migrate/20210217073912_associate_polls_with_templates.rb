class AssociatePollsWithTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :poll_template_id, :integer, null: true, default: nil
    PollTemplate.all.each do |template|
      Poll.where(poll_type: template.poll_type).update_all(poll_template_id: template.id)
    end
    change_column :polls, :poll_template_id, :integer, null: false
  end
end
