require 'sinatra'
require 'json'
require 'sinatra/json'
#test
class SingleGame

	attr_accessor :winningDoor, :firstDoor,:currentDoor,:willChangeDoor,:losingDoor,:isWinning

	def initialize(willChangeDoor)
		@winningDoor = randomize
		@firstDoor = randomize	
		@currentDoor = @firstDoor	
		@willChangeDoor = willChangeDoor
		openLosingDoor
		if(@willChangeDoor == true)
			changeDoor
		end
		if(@currentDoor == @winningDoor)
			@isWinning = true
		else
			@isWinning = false
		end
	end

	def openLosingDoor
		@losingDoor = randomize
		if(@losingDoor == @winningDoor || @losingDoor == @currentDoor)
			openLosingDoor
		end
	end

	def changeDoor
		@currentDoor = randomize
		if(@currentDoor == @losingDoor || @currentDoor == @firstDoor)
			changeDoor
		end
	end

	def to_json(*a)
		{winningDoor: @winningDoor,firstDoor: @firstDoor, willChangeDoor: @willChangeDoor,isWinning: @isWinning}.to_json(*a)
	end

	private
	def randomize
		return Random.rand(3)
	end

end

class GameCounter

	attr_accessor :winningTotal, :totalGames, :winningPercentage

	def initialize
		@totalGames	= 0
		@winningTotal = 0
		@winningPercentage = 0
	end

	def addGame(game)
		@totalGames	= @totalGames + 1
		@winningTotal = @winningTotal + 1 if game.isWinning == true
		@winningPercentage = @winningTotal.to_f / @totalGames.to_f * 100
	end

end

class GameWatcher

	attr_accessor :games,:winningTotal, :winningPercentage, :totalGames

	def initialize
		@counter = GameCounter.new
		@games = []
	end

	def addGame(game)
		@games << game
		@counter.addGame(game)	
		@winningTotal = @counter.winningTotal
		@winningPercentage = @counter.winningPercentage
		@totalGames = @counter.totalGames
	end

end

class GameRepetition

	attr_accessor :games,:winningTotal, :winningPercentage

	def initialize
		@watcher = GameWatcher.new
		@games = @watcher.games
		@winningTotal = @watcher.winningTotal
		@winningPercentage = @watcher.winningPercentage
	end

	def startGame(totalGames, willChangeDoor)
		totalGames.times do
			game = SingleGame.new(willChangeDoor)
			@watcher.addGame(game)
		end
		@games = @watcher.games
		@winningTotal = @watcher.winningTotal
		@winningPercentage = @watcher.winningPercentage
	end

	def to_json(*a)
		{games: @games, winningTotal: @winningTotal, winningPercentage: @winningPercentage}.to_json(*a)
	end
end



get '/' do
	erb :index 
end

get '/game' do
	games = GameRepetition.new
	games.startGame(params['change_door_repetition'].to_i,true)
	games.startGame(params['dont_change_door_repetition'].to_i, false)
	json games
end