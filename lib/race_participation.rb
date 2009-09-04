class RaceParticipation
  attr_accessor :ticks
  include DataMapper::Resource
  property :id, Serial

  belongs_to :racer
  belongs_to :race

  property :finish_time, BigDecimal

  def color
    @color ||= $BIKES[self.race.race_participations.index(self)]
  end

  def speed(stubbed)
    31
  end

  def percent_complete
    [1.0, self.distance / $RACE_DISTANCE].min
  end

  def distance
    self.ticks * $ROLLER_CIRCUMFERENCE
  end

  METERS_PER_MILLISECOND_TO_MILES_PER_HOUR = 2236.93629
  METERS_PER_MILLISECOND_TO_KILOMETERS_PER_HOUR = 3600.0
  def unit_conversion
    case UNIT_SYSTEM
      when :mph
        @unit_conversion = METERS_PER_MILLISECOND_TO_MILES_PER_HOUR
      when :kph
        @unit_conversion = METERS_PER_MILLISECOND_TO_KILOMETERS_PER_HOUR
    end
  end

  # yikes.
  def speed(time)
    @unit_conversion ||= unit_conversion
    @distance = self.distance
    @time = time
    @distance_old ||= 0
    @time_old ||= 0
    @speed ||= 0
    if(@time_old > @time)
      @time_old = time
    end
    if time == 0
      0
    else
      if(@time-@time_old > 999)
        if(@distance_old > 0)
          @speed = "%.2f" % (((@distance - @distance_old) / (@time - @time_old)) * @unit_conversion).to_f
        else
          @speed = 0
        end
        @distance_old = @distance
        @time_old = @time
      end
      @speed
    end
  end

end