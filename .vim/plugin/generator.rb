# Ruby's capitalize doesn't quite do what we want for wifi->Wi-Fi,
# since "Wi-Fi".capitalize => "Wi-fi"
def my_capitalize(s)
  s[0..0].upcase + s[1..-1]
end

output = File.open("autocorrect.vim", "w")
File.open("autocorrect.dat").each do |line|
  parts = line.chomp.split("->") # we don't want the line ending
  output.puts "ia #{parts[0]} #{parts[1]}"
  # if the words are already capitalized or the correction is capitalization, skip
  capitalized = my_capitalize(parts[0])
  unless capitalized == parts[0] || capitalized == parts[1]
    output.puts "ia #{capitalized} #{my_capitalize(parts[1])}"
  end
end
