file_path = ARGV[0]

lines = File.read(file_path).split("\n")
normalized_lines = lines.map do |line|
  line.split("/").map do |part|
    part[0] == ":" ? "{#{part[1..-1]}}" : part
  end.join("/")
end

output = normalized_lines.join("\n")

puts output
