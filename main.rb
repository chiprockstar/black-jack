require 'rubygems'
require 'sinatra'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'xyZ1W3Df2'

helpers do

  def calculate_total(cards)
    cards_arr = cards.map{ |element| element[1] }

    total = 0
    cards_arr.each do |card|
      if card == "Ace"
        total += 11
      else
        total += card.to_i == 0 ? 10 : card.to_i
      end
    end

    cards_arr.select { | element |  element == "Ace" }.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end


  def show_hand(card, visibility)
    image_path = 'images/cards/'
    if !visibility
       return image_path + "cover.jpg"
    end
    if card[0] == 'H'
      return image_path + "hearts_" + card[1].downcase + ".jpg"
    elsif card[0] == 'D'
      return image_path + "diamonds_" + card[1].downcase + ".jpg"
    elsif card[0] == 'C'
      return image_path + "clubs_" + card[1].downcase + ".jpg"
    elsif card[0] == 'S'
      return image_path + "spades_" + card[1].downcase + ".jpg"
    end
  end


  def calculate_only_visible
    if ['King', 'Jack', 'Queen'].include?(session[:dealer_showing][1])
      card_up = 10
    elsif session[:dealer_showing][1] == 'Ace'
      card_up = 11
    else
      card_up = session[:dealer_showing][1]
    end

    if session[:calc_dealer_total]
      total = calculate_total(session[:dealer_cards])
    elsif !session[:calc_dealer_total]
      total = card_up
    end
    total
  end


  def reset_game
    session[:card_visibility] = true
    session[:turn] = 'game_over'
    session[:calc_dealer_total] = true
    @play_again = true

  end


  def display_results(result, msg)
    if result == 'loss'
      session[:player_purse] -= session[:player_bet].to_i
      @error = msg + " #{session[:username]} has $#{session[:player_purse]}."
    elsif result == 'win'
      session[:player_purse] += session[:player_bet].to_i
      @success = msg + " #{session[:username]} has $#{session[:player_purse]}."
    elsif result == 'tie'
      @success = msg + " #{session[:username]} has $#{session[:player_purse]}."
    end
    reset_game
  end

  def win

  end

  def lose

  end

  def tie

  end

  def calculate_game_status
    dealer_cards = calculate_total(session[:dealer_cards])
    player_cards = calculate_total(session[:player_cards])
    player_turn = session[:turn]

    case
    when dealer_cards > 21
      display_results('win', "It looks like the dealer busted.
                    <strong>#{session[:username]} wins!</strong>")
    when player_cards > 21
      display_results('loss', "Sorry, it looks like
                    <strong>#{session[:username]} busted. The dealer
                     wins!</strong>")
    when dealer_cards == 21 && player_cards == 21
      display_results('loss', "Both dealer and
                    <strong>#{session[:username]}</strong> hit Blackjack so the
                     dealer wins!")
    when player_cards == 21
      display_results('win', "<strong>#{session[:username]}</strong> hit
                    Blackjack and wins!")
    when dealer_cards == 21
      display_results('loss', "Dealer hit Blackjack and
                    <strong>#{session[:username]}</strong> loses.")
    when dealer_cards >= 17
      if player_cards > dealer_cards && player_turn == 'dealer'
          display_results('win', "Dealer stays at #{dealer_cards} and
                        <strong>#{session[:username]} wins!</strong>")
      elsif player_cards == dealer_cards && player_turn == 'dealer'
        display_results('tie', "Dealer stays at #{dealer_cards} and it's a
                      tie!")
      elsif player_cards < dealer_cards && player_turn == 'dealer'
        display_results('loss', "Dealer stays and wins at #{dealer_cards}.
                      <strong>#{session[:username]}</strong> loses.")
      end
    when player_cards < dealer_cards && player_turn == 'dealer'
      display_results('loss', "Dealer stays and wins at #{dealer_cards}.
                    <strong>#{session[:username]}</strong> loses.")
    end
  end
end

#routes

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
    @error = "Your name is required"
    halt erb(:get_user)
  end

  if params[:username].count(/[ a-zA-Z]/.to_s) != params[:username].length
    @error = "Only letters are allowed."
    halt erb(:get_user)
  end
  session[:username] = params[:username]
  session[:player_purse] = 500
  redirect '/bet'
end

get '/bet' do
  if session[:player_purse].to_i == 0
    redirect '/game_over'
  end
  erb :bet
end

post '/bet' do
  if params[:bet].empty?
    @error = "Please place a bet."
    halt erb(:bet)
  elsif params[:bet].to_i > session[:player_purse].to_i
    @error = "Please place a bet less than or equal to
    $#{session[:player_purse]}"
    halt erb(:bet)
  elsif params[:bet].to_i <= 0
    @error = "Please place a bet greater than $0."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet]
    redirect '/'
  end
end

post '/player_hit' do
  session[:turn] = 'player'
  session[:player_cards] << session[:deck].pop
  session[:calc_dealer_total] = false
  calculate_game_status
  erb :game
end

post '/player_stay' do
  session[:turn] = 'dealer'
  session[:calc_dealer_total] = true
  calculate_game_status
  erb :game
end

post '/dealer_hit' do
  session[:dealer_cards] << session[:deck].pop
  calculate_game_status
  erb :game
end

get '/game_over' do
  erb :game_over
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
  session[:turn] = 'player'
  calculate_game_status
  erb :game
end
