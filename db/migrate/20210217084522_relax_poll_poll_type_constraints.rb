class RelaxPollPollTypeConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column :polls, :poll_type, :string, null: true, default: nil
  end
end
