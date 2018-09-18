require 'rubygems'
require 'bundler/setup'
require 'pry'

# class String
#   def xor(other)
#     ret = dup
#     ret.length.times { |n| ret[n]^=other[n] }
#     ret
#   end
# end

$ct = "0000010000101100001100010111001000110110001111010011110100100001011000110011001100101001001110000011011001100101001100000011000100101101001000110010011000101001011000110010011100101011001100000111001100100111001001100011101000101100001110100011011100100000001100010010011001101011011101000001000000101100001000100011110101101011011101000001010000100000001101110111001000101010001000010010011101100101001011000011010001100101001111010010011100110110011000110010010100100100001011010111110101100101000001110011110100101011011100110010011101100101001100110011111000100100001011010111001100100010001000100011111100100000001001110111001100110010001010100010011000101101011101000011101000110001011011010111001000001100001000000111010000110110011000110011001101100101001101100011101000100010011000110011110100101011001100010111111101100101001011100011001100111100001101100011011001100101001000100010000101100101001101100011101000100010011000110011001100110110011101000010011100101101001001100010101101100010001000100011011001100101001100000011011100100000001110100111111101100101001000100011110000100001011101000010011100110111001001100011111100100000001110100011011100101010001101100010000101100101001101010011111000101010001101100011110000110001001001110111001100101010001001010111001000110010001101010010011100100000001100010111110001100101000000000011101100100000011000110010000100110001001110110010000100101000011000110010010100101100001110000011111101100101001000000011110100101000001100010111110101100101000010100010011001100101001000110011101000101001001011110111001000100010001110110111110101100101000101000011011101100101001000110011001000101011001101110111001000100000001000100011011000110111001110100011000000101010001100000010101001100101001101110011110101100101001101100011011001100101001100000011001100100011001100010111110101100101000101000011011101100010001001100011011001100101001001010010011100101001001110000010101001100101001100110010000000100000001001000011001000110111001001100011011001111111011101000011010100101010001011000011011001101001011101000011111000100000001001110011101100100110001101010011111101101001011000110011011100110011001100010010000100111100001101110011101000101100001110100011010001100101001110100011110100110000011101000011000000100100001011010111001000101100001110010011001000100010001010100011110000100000011110000111001100110010001001100111001000100100001001100011011001100101001100010011011100100100001100000010101001101011"

ct_array = $ct.scan /.{8}/
ct_int_array = ct_array.map{|x| x.to_i(2)}
$ct_string = ct_int_array.pack('C*')

$ct_known_pt = ' Get out of its way.'
$ct_key_length = 6

def main

  plaintext = 'make America great again'

  filename = 'group_14.txt'

  key_length = 14

  encrypted = File.read(filename)

  #binding.pry
  crack(encrypted, plaintext, key_length)

end

def crack(ciphertext, known_plaintext, key_length)
  ciphertext_int_array = ciphertext.unpack('C*')

  tryouts = []

  for shift in 0..(known_plaintext.length - 1) do
    shifted_pt = known_plaintext[shift..-1] + known_plaintext[0, shift]

    puts "Taking #{shifted_pt} against ciphertext"

    known_plaintext_int_array = shifted_pt.unpack('C*')

    xor_d = ciphertext_int_array.each_with_index.map do |x, i|
      plaintext_index = i % (known_plaintext_int_array.length - 1)
      # xor(known_pt_int_array[plaintext_index], x)
      known_plaintext_int_array[plaintext_index] ^ x
    end
    tryouts.push xor_d.pack('C*')
  end

  tryouts.each do |tryout|
    #for chunk in tryout.scan(/.{1,#{key_length}}/) do
    #tryout.length
    chunk = tryout[0..13]
    while tryout.length > 0
      puts "Possible key: #{chunk}"
      raise "wrong length #{chunk.length}" if chunk.length != 14
      #raise 'KEY FOUND' if chunk == "\x8B0\xA3lh\x7F\xEB5\x13\xB3\xE3\x91vs"
      chunk = chunk[1..-1] + tryout[0]
      tryout = tryout[1..-1]

      #raise('KEY VALID') if validate_key(tryout, ciphertext, chunk)
    end
  end

  # magic_regexp = /(.{3,})(\1)/
  # magic_regexp = /[\w\d\s]{7,}/
  # magic_regexp = /[a-zA-Z\w\x0]{14,}/
  #
  # tryouts.each_with_index do |tryout, i|
  #   if tryout.match? magic_regexp
  #     match_data = tryout.scan(magic_regexp)
  #     key_candidates = match_data.flatten.uniq
  #     puts "Possible key candidates: #{key_candidates}"
  #     next
  #     #return
  #     key_candidates.each do |key_candidate|
  #       deshift_index = i - 1 #(i % key_candidate.length) - 1
  #       #deshifted_key = key_candidate.chars.rotate(- deshift_index).join
  #       puts "Possible key candidate: #{key_candidate} with shift #{i}"
  #
  #       for i in 0..key_candidate.length do
  #         rotated_key = key_candidate.chars.rotate(i).join
  #         puts "Testing #{rotated_key}"
  #         possible_plaintext = decrypt(ciphertext_int_array, rotated_key)
  #         key_valid = validate_key(possible_plaintext, ciphertext, rotated_key)
  #         puts "Key valid? #{key_valid}"
  #       end
  #
  #     end
  #   end
  # end

  return ''
end


def xor(msg, key)
  int_array = msg.unpack("C*")
  key_array = key.unpack("C*")

  xor_ed = int_array.each_with_index do |char, i|
    char ^ key_array[i % (key_array.length - 1) ]
  end

  xor_ed.pack("C*")
end

def validate_key(ciphertext, valid_ciphertext, key)
  reconstructed_ciphertext = xor(xor(ciphertext, key), key)
  return reconstructed_ciphertext == valid_ciphertext
end

def validate_decoder
  crack($ct_string, $ct_known_pt, $ct_key_length)
end

main


# Encryption
# E(key, plaintext) = plaintext XOR key

# Key: 110
# Plaintext: 1101101100101
# Known Plaintext: 011

# Encrypted: 0000000001000
# Cracking:  011011011011011
#-----------------------------
# XORed      0110110111110
# Plaintext  011011011011011
# -------------------------
#            0000000001000
