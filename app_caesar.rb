require 'rubygems'
require 'bundler/setup'
require 'pry'
#require 'statistics2'

def translate_to_number(text)
  uppercase_text = text.upcase

  uppercase_text.chars.map do |char|
    alphabet.index(char)
  end
end

def translate_to_string(number_array)
  string_array = number_array.map{ |number| alphabet[number] }.join('')
end

def alphabet
  ('A'..'Z').to_a
end

def shift_alphabet_index(index, shift)
  (index + shift) % 26
end

def encode(plaintext, shift)
  plaintext_array = translate_to_number(plaintext)
  encoded_array = plaintext_array.map { |number| shift_alphabet_index(number, shift) }
  translate_to_string encoded_array
end

def decode(ciphertext, shift)
  ciphertext_array = translate_to_number(ciphertext)
  decoded_array = ciphertext_array.map { |number| shift_alphabet_index(number, - shift) }
  translate_to_string(decoded_array)
end

def text_distribution(text)
  absolute_distribution = alphabet.map { |char| Float(text.count(char)) }

  absolute_distribution.map do |value|
    Float(value / absolute_distribution.sum)
  end
end

def word_distribution
  book_text = File.read('oliver_twist.txt')
  book_text_upcase = book_text.upcase
  distribution = text_distribution(book_text_upcase)
  binding.pry
end

puts(translate_to_number('helloworld') == [7, 4, 11, 11, 14, 22, 14, 17, 11, 3])
puts(translate_to_string([7, 4, 11, 11, 14, 22, 14, 17, 11, 3]) == 'HELLOWORLD')

puts(encode('helloworld', 26) == 'HELLOWORLD')
puts(decode('HELLOWORLD', 26) == 'HELLOWORLD')

puts(encode('helloworld', 4) == 'LIPPSASVPH')
puts(decode('LIPPSASVPH', 4) == 'HELLOWORLD')

word_distribution
