# -*- encoding : utf-8 -*-
module WithGameWeek
  DAYS_IN_A_WEEK = 7

  def self.validate_game_week_number(game_week_number)
    fail ArgumentError, game_week_too_small_message(game_week_number) if game_week_number < 1
    fail ArgumentError, game_week_too_large_message(game_week_number) if game_week_number > Settings.number_of_gameweeks
  end

  def self.game_week_too_small_message(game_week_number)
    "Game week number must be greater than 1, not #{game_week_number}"
  end

  def self.game_week_too_large_message(game_week_number)
    "Game week number must be less than #{Settings.number_of_gameweeks}, not #{game_week_number}"
  end

  def for_current_game_week(list)
    for_game_week(list, WithGameWeek.current_game_week)
  end

  def up_to_game_week(list, game_week_number)
    WithGameWeek.validate_game_week_number(game_week_number)
    list.select do |item|
      item.game_week.number <= game_week_number
    end
  end

  def for_game_week(list, game_week_number)
    WithGameWeek.validate_game_week_number(game_week_number)
    candidates = all_with_correct_game_week(list, game_week_number)

    fail ActiveRecord::RecordNotFound, no_candidate_message(id, game_week_number) if candidates.empty?
    fail IllegalStateError, multiple_candidates_message(candidates.size, id, game_week_number) if candidates.size > 1

    candidates.first
  end

  def self.start_of_first_gameweek
    Time.zone = 'Eastern Time (US & Canada)'
    Time.zone.parse(Settings.first_gameweek_start) + 2.hours
  end

  def self.eastern_current_time
    DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
  end

  def self.more_than_days_since_start?(days)
    more_than_time_since_start?(days, 0)
  end

  def self.more_than_time_since_start?(days, hours)
    eastern_current_time = WithGameWeek.eastern_current_time
    time_difference = eastern_current_time - WithGameWeek.start_of_first_gameweek

    total_converted_time = days.days + hours.hours

    time_difference > total_converted_time
  end

  def self.current_game_week
    eastern_current_time = WithGameWeek.eastern_current_time
    augmented_start_time = WithGameWeek.start_of_first_gameweek

    days_since_start = ((eastern_current_time - augmented_start_time) / 1.day).floor

    game_week = ((days_since_start - (days_since_start % DAYS_IN_A_WEEK)) / DAYS_IN_A_WEEK) + 1

    return 1 if game_week < 1
    game_week
  end

  private

  def all_with_correct_game_week(list, game_week_number)
    list.select do |item|
      item.game_week.number == game_week_number
    end
  end

  def no_candidate_message(id, game_week_number)
    "Nothing found for id #{id}, game week #{game_week_number}"
  end

  def multiple_candidates_message(size, id, game_week_number)
    "#{size} found with id #{id}, game week #{game_week_number}"
  end
end
