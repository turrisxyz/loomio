class PollTemplate < ApplicationRecord
  POLL_TYPES = %w[proposal poll count score ranked_choice meeting dot_vote]

  def has_score_icons
    poll_type == 'meeting'
  end
end
