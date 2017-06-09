class Hangman
  attr_reader :guesser, :referee, :board

  def initialize(players)
    @guesser = players[:guesser]
    @referee = players[:referee]
  end

  def setup
    secret_word = @referee.pick_secret_word
    @guesser.register_secret_length(secret_word)
    @board = Array.new(secret_word)
  end

  def take_turn
     new_guess = @guesser.guess(@board)
     indices = @referee.check_guess(new_guess)
     update_board(new_guess, indices)
     guesser.handle_response(new_guess, indices)
  end

  def update_board(guess, pos)
     pos.each { |idx| @board[idx] = guess }
  end

   def display_board
     display = @board.map {|el| el == nil ? el = "__" : el}
       p display
    end

    def won?
      !@board.include?(nil)
    end

    def play
      setup
      display_board
      (0..10).each do
        take_turn
        display_board
        if won?
          puts "Guesser wins!"
          return
        end
      end
      puts "Referee Wins!"
      puts referee.hidden_word
    end

end

class HumanPlayer
  def initialize
      @secret_word = nil
      @secret_length = nil
    end

    def pick_secret_word
      puts "type the length of the secret_word"
      @secret_word = gets.chomp.to_i
    end

    def register_secret_length(length)
      @secret_length = length
    end

    def check_guess(letter)
      puts "The letter guessed is #{letter}"
      puts "enter the index of the character if it's in your word seperated by commas"
      pos = gets.chomp.split(",").map { |idx| idx.to_i }
    end

    def guess(board)
    puts "guess a letter"
    guess = gets.chomp
    end

    def handle_response(guess, pos)
      puts "Found #{guess} at positions #{pos}"
    end

    def hidden_word
      puts "What was the word?"
      gets.chomp
    end
end

class ComputerPlayer
  attr_reader :candidate_words

   def self.dict_file(file_name)
    ComputerPlayer.new(File.readlines(file_name).map{|line| line.chomp})
  end

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def pick_secret_word
    @secret_word = @dictionary.sample
    @secret_word.length
  end

  def check_guess(letter)
    indices = []
    @secret_word.chars.each_with_index do |x, idx|
      if letter == x
        indices << idx
      end
    end
    indices
  end

  def register_secret_length(length)
    @secret_length = length
    @candidate_words = @dictionary.select {|word| word.length == @secret_length}
  end

  def guess(board)
    counter = Hash.new(0)
    candidate_words.each do |word|
      word.chars {|letter| counter[letter] += 1 unless board.include?(letter)}
    end
    counter.key(counter.values.max)
  end

  def handle_response(guess, pos)
    candidate_words.reject! do |word|
    delete_this = false
    word.split("").each_with_index do |letter, idx|
      if letter == guess && (!pos.include?(idx))
      delete_this = true
        break
          elsif letter != guess && pos.include?(idx)
          delete_this = true
        break
      end
    end
    delete_this
    end
  end

 def hidden_word
    @secret_word
 end
end

  if __FILE__ == $PROGRAM_NAME
    print "Guesser: Computer (yes/no)? "
    if gets.chomp == "yes"
      guesser = ComputerPlayer.dict_file("lib/dictionary.txt")
    else
      guesser = HumanPlayer.new
    end

    print "Referee: Computer (yes/no)? "
    if gets.chomp == "yes"
      referee = ComputerPlayer.dict_file("lib/dictionary.txt")
    else
      referee = HumanPlayer.new
    end

    Hangman.new({guesser: guesser, referee: referee}).play
  end
