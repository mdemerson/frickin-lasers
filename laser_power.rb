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
puts "what is the wavelength of your fibre?"
print "'a' for 1550nm SMOF any other key for 1310: "
wavelength = gets.chomp()

# Create hashes.
premises = Hash.new
worst_case = Hash.new
total_loss = Hash.new

# Create counters and defaults.
premises_counter = 1
worst_case_counter = 0
wavelength_name = "1550nm"
optimal_light = 0

###### Methods ######

# Perform calculations to get DB loss at different wavelengths
def db_loss(distance, wavelength, splices, connections)
  if wavelength == "a"
    wavelength_calc = 0.21
  else
    wavelength_calc = 0.35
  end
  return (distance * wavelength_calc) + (splices * 0.10) + (connections * 0.30)
end

# Ask questions for each premises.
def premises_query(number, wavelength)
  # Get premises details and put them into 'premises' hash.
  puts ""
  print "What is the fibre distance (in KM's) from the ODF to premises #{number}? "
  premises_distance = gets.to_f
  print "How many splices between the ODF and premises #{number}? "
  premises_splices = gets.to_i
  print "how many connections between the ODF and premises #{number} (including ODF)? "
  premises_connections = gets.to_i
  return db_loss(premises_distance, wavelength, premises_splices, premises_connections)
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

# Change the wavelength name if necessary.
unless wavelength == "a"
  wavelength_name = "1310nm"
end

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

backbone_db_loss = db_loss(backbone_distance, wavelength, backbone_splices, backbone_connections) + 19

# Calls the premises query
while premises_counter <= premises_amount
  premises["#{premises_counter.to_s}"] = premises_query(premises_counter, wavelength)
  premises_counter += 1
end

# Work out which premises has the highest loss
premises.each do |number, value|
  unless value < worst_case_counter
    worst_case_counter = value
    worst_case = {"#{number.to_s}" => value}
  end
end

# Work out the optimal light
optimal_light = -18 + (worst_case.values.first + backbone_db_loss)


###### Print out the results ######

# Clear screen
40.times do puts "" end

# A bit of basic info.
puts "We are using #{wavelength_name} SMOF to go to #{premises_amount} premises."
puts ""
puts "OLT to ODF loss is #{backbone_db_loss.round(2)}."
puts ""
puts "Premises #{worst_case.keys.first} has the greatest loss, -#{(worst_case.values.first).round(2)} dB (-#{(worst_case.values.first + backbone_db_loss).round(2)} dB total) ."
puts ""

# Print out loss from ODF to each premises.
premises.each do |number, value|
  puts "premises #{number} has loss of -#{value.round(2)} dB, -#{(value + backbone_db_loss).round(2)} dB total."
  total_loss["#{number.to_s}"] = (value + backbone_db_loss).round(2)
end

# Print out light reading at each premises.
total_loss.each do |number, value|
  puts ""
  puts "premises #{number} will have a light reading of #{(optimal_light - value).round(2)} dBm."
  if (optimal_light - value) > -8
    puts "*** THIS CONNECTION WILL NEED TO BE ATTENUATED ***"
  end
end

# Print out required laser power.
puts ""
puts "You will require a laser capable of emitting at least #{dbm_to_mw(optimal_light).round(2)} mW."
