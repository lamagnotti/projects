class NumberGuess
  MAX_GUESSES = 9
  RANGE = 1..100

  attr_reader :guesses
  attr_accessor :name

  def initialize
    @guesses = MAX_GUESSES
    @number = RANGE.to_a.sample
    @win = false
  end

  def set_name
    n = ""
    loop do
      puts "What's your first name?"
      n = gets.chomp.capitalize
      clear
      break unless n.strip.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def welcome_message
    puts "Welcome to **  GUESS A NUMBER!  **"
    puts "------------------------------"
    puts "                              "
  end

  def display_name
    puts "Good luck #{name}. You're going to need it! :)"
  end

  def goodbye_message
    puts "Goodbye #{name}! Thanks for playing **  GUESS A NUMBER!  **"
  end

  def choose_number
    loop do
      puts "Please enter a number between #{RANGE.first} and #{RANGE.last}:"
      guess = gets.chomp.to_i
      return guess if RANGE.cover? guess
      puts "Invalid guess. Please try again."
    end
  end

  def guess_logic(guess)
    if guess > @number
      puts "Your guess is too high!"
    elsif guess < @number
      puts "Your guess is too low!"
    else
      @win = true
    end
  end

  def guesses_remaining
    if guesses == 1
      puts "You have #{guesses} guess remaining."
      double_line
    elsif guesses <= 2
      puts "Yikes! You're getting close! Only #{guesses} left! Choose wisely!"
      double_line
    else
      puts "You have #{guesses} guesses remaining."
      double_line
    end
  end

  def decrement_guesses
    @guesses -= 1
  end

  def display_winner
    if @win
      puts "Congratulations! You correctly guessed #{@number}!"
    else
      puts "Sorry, you lose. The correct answer was #{@number}."
    end
  end

  def clear
    system 'clear'
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n', 'yes'].include? answer.downcase
      puts "Sorry, must be y or n."
    end
    # Added option for 'yes' just incase people go off the beaten path
    answer == 'y' || answer == 'yes'
  end

  def reset_game
    clear
    @guesses = MAX_GUESSES
    @number = RANGE.to_a.sample
    @win = false
  end

  def line
    puts "------------------------------------------"
  end

  def double_line
    puts "=========================================="
  end

  def intro_gameplay
    clear
    welcome_message
    set_name
    display_name
  end

  def main_gameplay
    guesses_remaining
    guess = choose_number
    clear
    guess_logic(guess)
    line
    decrement_guesses
  end

  def play
    intro_gameplay
    loop do
      loop do
        main_gameplay
        break if @win || @guesses == 0
      end
      display_winner
      line
      break unless play_again?
      reset_game
    end
    goodbye_message
  end
end

game = NumberGuess.new
game.play
