SCORE_TO_WIN = 5

module UI
  def clear_screen
    system('clear') || system('cls')
  end

  def line
    puts "------------------------------------------"
  end

  def space
    puts "                                          "
  end
end

class Move
  attr_reader :value
  VALUES = ["rock", "paper", "scissors", "lizard", "spock"].freeze

  SHORTCUTS = { 'r' => 'rock',
                'p' => 'paper',
                's' => 'scissors',
                'l' => 'lizard',
                'sp' => 'spock' }.freeze

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end

  def >(other_move)
    (rock? && (other_move.scissors? || other_move.lizard?)) ||
      (paper? && (other_move.rock? || other_move.spock?)) ||
      (scissors? && (other_move.paper? || other_move.lizard?)) ||
      (lizard? && (other_move.paper? || other_move.spock?)) ||
      (spock? && (other_move.rock? || other_move.scissors?))
  end

  def <(other_move)
    (rock? && (other_move.paper? || other_move.spock?)) ||
      (paper? && (other_move.scissors? || other_move.lizard?)) ||
      (scissors? && (other_move.rock? || other_move.spock?)) ||
      (lizard? && (other_move.scissors? || other_move.rock?)) ||
      (spock? && (other_move.paper? || other_move.lizard?))
  end

  def to_s
    @value
  end
end

#------------------------------------------------------------------------------#

class Player
  attr_accessor :move, :name, :score

  def initialize
    @score = 0
    set_name
  end
end

#------------------------------------------------------------------------------#

class Human < Player
  include UI

  def set_name
    n = ""
    loop do
      puts "What's your first name?"
      n = gets.chomp.capitalize
      clear_screen
      break unless n.strip.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def display_choices
    line
    puts "Please press:"
    puts "| 'r'  |  'p'  |   's'    |   'l'  | 'sp'  |"
    puts "| for  |  for  |   for    |   for  |  for  |"
    puts "| rock | paper | scissors | lizard | spock |"
    line
  end

  def choose
    choice = nil
    loop do
      display_choices
      choice = gets.chomp.downcase
      if Move::VALUES.include? choice
        break
      elsif Move::SHORTCUTS.keys.include? choice
        choice = Move::SHORTCUTS[choice]
        break
      end
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

#------------------------------------------------------------------------------#

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Mr.Robot', 'DJKhaled'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

#------------------------------------------------------------------------------#

module Display
  include UI
  def display_welcome_message
    puts "Hey #{human.name}! Welcome to Rock, Paper, Scissors!"
    puts "First one to #{SCORE_TO_WIN} points wins!"
    line
    puts "Press any key to PLAY!"
    gets.chomp
    puts "Good luck!"
    sleep 2
    clear_screen
  end

  def display_goodbye_message
    puts "Thanks for playing RPSLS #{human.name}! Bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_score
    line
    puts "#{human.name}: #{human.score} | #{computer.name}: #{computer.score}"
    line
  end
end

#------------------------------------------------------------------------------#

class RPSGame
  include Display
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def game_winner
    human.score > computer.score ? human : computer
  end

  def game_winner_name
    space
    space
    puts "             |       |
            (| Congr |)
             |  ats! |
              \       /
               `---'
               _|_|_"
    puts "     #{game_winner.name} wins the whole enchilada!".upcase
    space
    space
    line
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

  def update_score
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def winner?
    (human.score == SCORE_TO_WIN) || (computer.score == SCORE_TO_WIN)
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end

  def reset_game
    clear_screen
    reset_scores
  end

  def make_moves
    human.choose
    computer.choose
  end

  def main_gameplay
    clear_screen
    update_score
    display_score
    display_moves
    space
    display_winner
  end

  def play
    clear_screen
    display_welcome_message
    loop do
      loop do
        make_moves
        main_gameplay
        break if winner?
      end
      game_winner_name
      break unless play_again?
      reset_game
    end
    display_goodbye_message
  end
end

RPSGame.new.play
