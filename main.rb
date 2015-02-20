require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    arr = cards.map{ |element| element[1] }

    total = 0
    arr.each do |a|
      if a == "Ace"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    arr.select { | element |  element == "Ace" }.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end

  # images/cards/clubs_10.jpg
  def show_hand(card, visibility)
    image_path = 'images/cards/'

    if visibility == false
       return image_path + "cover.jpg"
    end

    if card[0] == 'H'
      return image_path + "hearts_" + card[1] + ".jpg"

    elsif card[0] == 'D'
      return image_path + "diamonds_" + card[1] + ".jpg"
    elsif card[0] == 'C'
      return image_path + "clubs_" + card[1] + ".jpg"
    elsif card[0] == 'S'
      return image_path + "spades_" + card[1] + ".jpg"
    else

    end
	end

		def calculate_only_visible
			if session[:dealer_showing][1] == 'Jack' || session[:dealer_showing][1] == 'Queen' || session[:dealer_showing][1] == 'King'
				card_up = 10
			elsif session[:dealer_showing][1] == 'Ace'
				card_up = 11
			else
				card_up = session[:dealer_showing][1]
			end

			if session[:calc_dealer_total]
				total = calculate_total(session[:dealer_cards])
			end
			if !session[:calc_dealer_total]
				total = card_up
			end
			total
		end

end










get '/' do
  session[:turn] = 'player'
  if session[:username]
    redirect '/game'
  else
    redirect '/get_user'
  end
end

get '/get_user' do
  erb :get_user
end

post '/get_user' do
	if params[:username].empty?
		@error = "Name is required"
		halt erb(:get_user)
	end
  session[:username] = params[:username]
  redirect '/'
end

post '/player_hit' do
  #erb :player_hit
  session[:turn] = 'player'
  session[:player_cards] << session[:deck].pop
  session[:calc_dealer_total] = false
	if calculate_total(session[:player_cards]) > 21
		@error = "Sorry, it looks like #{session[:username]} busted."
	end
  erb :game
end

post '/player_stay' do
  session[:turn] = 'dealer'
  session[:calc_dealer_total] = true
  erb :game

end

post '/dealer_hit' do
#	session[:turn] = 'dealer'
  session[:dealer_cards] << session[:deck].pop
	if calculate_total(session[:dealer_cards]) > 21
		@error = "Sorry, it looks like the dealer busted."
	end
  erb :game
end

get '/game' do
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5','6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  session[:deck] = suits.product(values).shuffle!
  session[:card_visibility] = false
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_showing] = session[:deck].pop
  session[:dealer_cards] << session[:dealer_showing]
  session[:player_cards] << session[:deck].pop
  session[:calc_dealer_total] = false
  erb :game

end
