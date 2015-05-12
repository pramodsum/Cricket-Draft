# -*- encoding : utf-8 -*-
class NflPlayerType < ActiveRecord::Base
  QB = :QB
  WR = :WR
  RB = :RB
  TE = :TE
  D = :D
  K = :K

  ALLOWED_TYPES = [QB, WR, RB, TE, D, K]

  def self.find_unique_with(position)
    npt_obj_list = NflPlayerType.where(position_type: position)

    # There should only we one of these
    no_of_npt_objs = npt_obj_list.size
    if no_of_npt_objs == 0
      fail ActiveRecord::RecordNotFound, "Didn't find a player type '#{position}'"
    elsif no_of_npt_objs > 1
      fail IllegalStateError, "Found #{no_of_npt_objs} player types with position '#{position}'"
    end

    # Return what must be the only element
    npt_obj_list.first
  end

  has_many :nfl_players

  validates :position_type,
            uniqueness: true,
            inclusion: { in: ALLOWED_TYPES, allow_nil: false }
end
