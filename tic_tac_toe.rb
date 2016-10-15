# frozen_string_literal : true

WINNING_SCORE = 4

# UI Module
module UI
  def single_horiz_rule
    puts '--------------------------------------------------'
  end

  def double_horiz_rule
    puts '==================================================='
  end

  def empty_rule
    puts '                                                   '
  end
end

# All Display Methods
module Display
  def clear
    system('clear') || system('cls')
  end

  def display_welcome_message
    puts 'Hello! Welcome to Tic-Tac-Toe!'
    puts "First one to win #{WINNING_SCORE} wins!"
    double_horiz_rule
  end

  def display_player_message
    puts "Good luck #{human.name}!"
    empty_rule
    puts "You'll be playing against #{computer.name} today."
    double_horiz_rule
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're a #{human.marker}. #{computer.name} is an #{computer.marker}."
    single_horiz_rule
    puts ''
    board.draw
    puts ''
    display_score
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won #{human.name}!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
    double_horiz_rule
  end

  def display_score
    puts 'The score is:'
    puts "#{human.name}: #{human.score}."
    puts "#{computer.name}: #{computer.score}"
    single_horiz_rule
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def display_overall_winner
    puts ''
    case board.winning_marker
    when human.marker
      puts "Ding-Ding-Ding! That's a wrap folks! #{human.name} wins!!!"
    when computer.marker
      puts "Ding-Ding-Ding! That's a wrap folks! #{computer.name} wins!!!"
    end
  end
end

#---------------------------------------------------------------------------#

# Board Class
class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      marked_squares = squares.select { |value| value.marker == marker }
      next unless marked_squares.count == 2
      squares = @squares.select do |key, value|
        line.include?(key) && value.marker == Square::INITIAL_MARKER
      end
      squares.keys.first
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

#---------------------------------------------------------------------------#

# Square Class
class Square
  INITIAL_MARKER = ' '.freeze

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

#---------------------------------------------------------------------------#

# Main Player Class
class Player
  VALID_MARKERS = %w(X O).freeze

  include Display

  attr_reader :marker
  attr_accessor :score, :name

  def initialize
    @marker = nil
    @score = 0
  end
end

#---------------------------------------------------------------------------#

# Human Player Class
class Human < Player
  def set_name
    n = ''
    loop do
      puts 'What is your first name?'
      n = gets.chomp.capitalize
      clear
      break unless n.strip.empty?
      puts 'Sorry, must enter a value.'
    end
    self.name = n
  end

  def choose_marker
    choice = nil
    puts "Choose your marker: #{VALID_MARKERS.join(' or ')}"
    loop do
      choice = gets.chomp.upcase
      break if VALID_MARKERS.include?(choice)
      puts 'Please enter a valid marker.'
    end
    @marker = choice
  end
end

#---------------------------------------------------------------------------#

# Computer Player Class
class Computer < Player
  COMPUTER_NAMES = ['BlackBeard', 'CaptainKidd', 'Tom from MySpace'].freeze

  def set_name
    self.name = COMPUTER_NAMES.sample
  end

  def choose_marker(other_marker)
    valid_choices = VALID_MARKERS
    valid_choices -= [other_marker]
    @marker = valid_choices.sample
  end
end

#---------------------------------------------------------------------------#

# Main Game Class
class TTTGame
  include UI
  include Display

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @current_marker = nil
  end

  #----------------------------------------#

  def play
    setup_game
    loop do
      display_board
      gameplay
      display_result
      update_score
      reset_match
      break unless play_again?
      reset
      display_play_again_message
    end
    display_goodbye_message
  end

  #----------------------------------------#

  private

  def gameplay
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board
    end
  end

  def setup_game
    clear
    display_welcome_message
    set_names
    display_player_message
    human.choose_marker
    computer.choose_marker(human.marker)
    single_horiz_rule
    choose_first
    game_load
  end

  def game_load
    sleep 1
    puts 'Game Loading...'
    sleep 1
    clear
  end

  def set_names
    human.set_name
    computer.set_name
  end

  def reset_match
    if overall_winner?
      clear_screen_and_display_board
      display_overall_winner
      reset_score
    end
  end

  def choose_first
    answer_prompt
    if @answer == 1
      @current_marker = human.marker
      puts 'You are going first!'
    elsif @answer == 2
      @current_marker = computer.marker
      puts 'The computer is first!'
    else
      @current_marker = [human.marker, computer.marker].sample
      puts "Looks like #{@current_marker} is going first!"
    end
  end

  def answer_prompt
    @answer = ''
    loop do
      puts 'Please select who goes first:'
      puts "(1) #{human.name}"
      puts "(2) #{computer.name}"
      puts "(3) I'm Feeling Lucky"
      @answer = gets.chomp.to_i
      break if [1, 2, 3].include?(@answer)
      puts 'Please enter a vaild choice.'
    end
  end

  def human_moves
    puts "Choose a square (#{board.unmarked_keys.join(', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    square = board.find_at_risk_square(human.marker)
    square = board.find_at_risk_square(computer.marker) unless square
    square = 5 if !square && board.unmarked_keys.include?(5)
    square = board.unmarked_keys.sample unless square
    board[square] = computer.marker
  end

  def overall_winner?
    [human.score, computer.score].include?(WINNING_SCORE)
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def reset_score
    human.score = 0
    computer.score = 0
  end

  def current_player_moves
    if @current_marker == human.marker
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts 'Sorry, must be y or n'
    end

    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = human.marker
    clear
  end
end

game = TTTGame.new
game.play
