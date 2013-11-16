helpers do
  def movie_rating(actor)
    search = Tmdb::Search.new
    search.resource('person')
    search.query(actor)
    result = search.fetch
    credits = Tmdb::People.credits(result.first['id'])
    movie_id = credits['cast'].map { |cast| cast['id'] }
    movie_rating = movie_id.take(15).map { |mov| Tmdb::Movie.detail(mov).vote_average }
    avg_score = movie_rating.inject(:+)/movie_rating.length
    avg_score
  end

  def cache_actor(actor_name)
    if Actor.exists?(:name_lowercase => actor_name.downcase) == false
      Actor.create name: actor_name, name_lowercase: actor_name.downcase, avg_rating: movie_rating(actor_name)
    end
  end

  def cache_fight(first_actor, second_actor)
    if Fight.exists?(:first_actor => first_actor.name_lowercase, :second_actor => second_actor.name_lowercase)
      Fight.where(:first_actor => first_actor.name_lowercase, :second_actor => second_actor.name_lowercase).first.increment!(:access_count)
    elsif Fight.exists?(:first_actor => second_actor.name_lowercase, :second_actor => first_actor.name_lowercase)
      Fight.where(:first_actor => second_actor.name_lowercase, :second_actor => first_actor.name_lowercase).first.increment!(:access_count)
    else
      Fight.create first_actor: first_actor.name_lowercase, second_actor: second_actor.name_lowercase, access_count: 1
    end
  end

  def win(first_actor, second_actor)
    return first_actor.name if first_actor.avg_rating > second_actor.avg_rating
    return second_actor.name if second_actor.avg_rating > first_actor.avg_rating
  end

end
