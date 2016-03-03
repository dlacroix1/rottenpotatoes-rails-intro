class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    ratings()
    sort_missing = false
    ratings_missing = false
    
    # initialize @sort
    if params.has_key?(:sort)
      @sort = params[:sort]
      session[:sort] = params[:sort]
    elsif session.has_key?(:sort)
      @sort = session[:sort]
      sort_missing = true
    else
      @sort = ""
    end
    
    # initialize @ratings
    if params.has_key?(:ratings)
      @ratings = params[:ratings].keys
      session[:ratings] = params[:ratings]
    elsif session.has_key?(:ratings)
      @ratings = session[:ratings].keys
      ratings_missing = true
    else
      @ratings = @all_ratings
    end
    
    # URI incomplete, so redirect
    if sort_missing && ratings_missing
      flash.keep
      redirect_to movies_path({:sort => session[:sort], :ratings => session[:ratings]})
    elsif sort_missing && !params.has_key?(:ratings)
      flash.keep
      redirect_to movies_path({:sort => session[:sort]})
    elsif ratings_missing && !params.has_key?(:sort)
      flash.keep
      redirect_to movies_path({:ratings => session[:ratings]})
    elsif sort_missing
      flash.keep
      redirect_to movies_path({:sort => session[:sort], :ratings => params[:ratings]})
    elsif ratings_missing
      flash.keep
      redirect_to movies_path({:sort => params[:sort], :ratings => session[:ratings]})
    end
    
    # Filter movies based on rating
    if @ratings.length > 0
      @movies = []
      @ratings.each do |checked|
        Movie.where("rating = ?", checked).find_each do |movie|
          @movies += [movie]
        end
      end
    else
      @movies = Movie.all
    end
    
    # Sort movies based on the selected header
    if @sort.length > 0
      if @sort == "title"
        @movies.sort! {|a, b| a.title <=> b.title}
      elsif @sort == "release_date"
        @movies.sort! {|a, b| a.release_date <=> b.release_date}
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def ratings
    @all_ratings = []
    Movie.all.each do |movie|
      if !@all_ratings.include? movie.rating
        @all_ratings += [movie.rating]
      end
    end
    @all_ratings
  end
  
end
