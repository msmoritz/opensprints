class ObsTournamentParticipation
  include DataMapper::Resource
  property :id, Serial
  property :eliminated, Boolean

  belongs_to :obs_racer
  belongs_to :obs_tournament

  def best_time
    best = ObsRaceParticipation.first("obs_race.obs_tournament_id" => obs_tournament.id,
                            :obs_racer_id => obs_racer.id,
                            :order => [:finish_time.asc]
    )
    best.finish_time if best
  end

  def rank
    standings = self.obs_tournament.obs_tournament_participations.sort_by{|tp|[tp.best_time||Infinity]}
    standings.index(self)+1
  end

  def losses
    (ObsRaceParticipation.all(:obs_racer_id => self.obs_racer_id, "obs_race.obs_tournament_id" => self.obs_tournament_id).select {|rp| rp.obs_race.winner != rp }).length
  end

  def race_participations
    ObsRaceParticipation.all("obs_race.obs_tournament_id" => obs_tournament.id,
                          :obs_racer => obs_racer)
  end

  def eliminate
    self.update_attributes(:eliminated => true)
  end
end