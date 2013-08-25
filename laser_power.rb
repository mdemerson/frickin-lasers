# Works out the power required for the fricken laser beams
# as per the Australian NBN standards.
#
# 0.35 dB loss per kilometre (1310nm SMOF)
# 0.21 dB loss per kilometre (1550nm SMOF)
# 0.10 dB loss per fusion splice
# 0.30 dB loss per connection
# 19 dB loss at 32 way splitter (ODF)
#
# -8  dBm = max light reading
# -18 dBm = optimal light reading
# -28 dBm = minimal light reading
#
# Mathew Emerson - 24/08/13

# Before we do anything else, find out the wavelength of the fibre.
# puts "what is the wavelength of your fibre?"
# print "'a' for 1550nm SMOF any other key for 1310: "
# wavelength = gets.chomp()

# Create hashes.
premises_1310 = Hash.new
premises_1550 = Hash.new
worst_case_1310 = Hash.new
worst_case_1550 = Hash.new
total_loss_1310 = Hash.new
total_loss_1550 = Hash.new

# Create counters and defaults.
premises_counter = 1
worst_case_counter_1310 = 0
worst_case_counter_1550 = 0
optimal_light_1310 = 0
optimal_light_1550 = 0


###### Methods ######

# Perform calculations to get DB loss at different wavelengths
def db_loss(distance, wavelength, splices, connections)
  return (distance * wavelength) + (splices * 0.10) + (connections * 0.30)
end

# Convert dBm to mW
def dbm_to_mw(dbm)
  return 10 ** (dbm / 10)
end

# Convert mW to dBm
def mw_to_dbm(mw)
  return Math.log10(mw) * 10
end


###### Program ######

# Establish how many connections there are going to be.
puts ""
print "How many premises are we running fibre to? "
premises_amount = gets.to_i

# Get backbone details.
puts ""
print "What is the distance from the OLT to the ODF (in KM's)? "
backbone_distance = gets.to_f
print "How many splices between OLT and ODF? "
backbone_splices = gets.to_i
print "How many connections are between the OLT and ODF? "
backbone_connections = gets.to_i

backbone_db_loss_1310 = db_loss(backbone_distance, 0.35, backbone_splices, backbone_connections) + 19
backbone_db_loss_1550 = db_loss(backbone_distance, 0.21, backbone_splices, backbone_connections) + 19

# Calls the premises querys
while premises_counter <= premises_amount
  puts ""
  print "What is the fibre distance (in KM's) from the ODF to premises #{premises_counter}? "
  premises_distance = gets.to_f
  print "How many splices between the ODF and premises #{premises_counter}? "
  premises_splices = gets.to_i
  print "how many connections between the ODF and premises #{premises_counter} (including ODF)? "
  premises_connections = gets.to_i

  premises_1310["#{premises_counter.to_s}"] = db_loss(premises_distance, 0.35, premises_splices, premises_connections)
  premises_1550["#{premises_counter.to_s}"] = db_loss(premises_distance, 0.21, premises_splices, premises_connections)

  premises_counter += 1
end

# Work out which premises has the highest loss
premises_1310.each do |number, value|
  unless value < worst_case_counter_1310
    worst_case_counter_1310 = value
    worst_case_1310 = {"#{number.to_s}" => value}
  end
end

premises_1550.each do |number, value|
  unless value < worst_case_counter_1550
    worst_case_counter_1550 = value
    worst_case_1550 = {"#{number.to_s}" => value}
  end
end

# Work out the optimal light
optimal_light_1310 = -18 + (worst_case_1310.values.first.to_f + backbone_db_loss_1310)
optimal_light_1550 = -18 + (worst_case_1550.values.first.to_f + backbone_db_loss_1550)

###### Print out the results ######

# Clear screen
40.times do puts "" end

# A bit of basic info.
puts "OLT to ODF loss is #{backbone_db_loss_1310.round(2)} @ 1310nm."
puts "OLT to ODF loss is #{backbone_db_loss_1550.round(2)} @ 1550nm."
puts ""
puts "Premises #{worst_case_1310.keys.first} has the greatest loss, -#{(worst_case_1310.values.first).round(2)} dB (-#{(worst_case_1310.values.first + backbone_db_loss_1310).round(2)} dB total) @ 1310nm."
puts "Premises #{worst_case_1550.keys.first} has the greatest loss, -#{(worst_case_1550.values.first).to_f.round(2)} dB (-#{(worst_case_1550.values.first.to_f + backbone_db_loss_1550).to_f.round(2)} dB total) @ 1550nm."
puts ""

# Print out loss from ODF to each premises.
premises_1310.each do |number, value|
  puts "premises #{number} has loss of -#{value.round(2)} dB, -#{(value + backbone_db_loss_1310).round(2)} dB total @ 1310nm."
  total_loss_1310["#{number.to_s}"] = (value + backbone_db_loss_1310).round(2)
end
puts ""

# Print out loss from ODF to each premises.
premises_1550.each do |number, value|
  puts "premises #{number} has loss of -#{value.round(2)} dB, -#{(value + backbone_db_loss_1550).round(2)} dB total @ 1550nm."
  total_loss_1550["#{number.to_s}"] = (value + backbone_db_loss_1550).round(2)
end
puts ""

# Print out light reading at each premises.
total_loss_1310.each do |number, value|
  puts "premises #{number} will have a light reading of #{(optimal_light_1310 - value).round(2)} dBm @ 1310nm."
end
puts ""

total_loss_1550.each do |number, value|
  puts "premises #{number} will have a light reading of #{(optimal_light_1550 - value).round(2)} dBm @ 1550nm."
end
puts ""

# Print out required laser power.
puts "You will require a laser capable of emitting at least #{dbm_to_mw(optimal_light_1310).round(2)} mW for 1310nm."
puts "You will require a laser capable of emitting at least #{dbm_to_mw(optimal_light_1550).round(2)} mW for 1550nm."
