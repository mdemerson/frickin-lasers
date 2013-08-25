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

# Create counters and defaults.
premises_counter = 1
worst_case_counter = 0
wavelength_name = "1550nm"


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
  print "What is the fibre distance (in KM's) from the ODF to premises #{number}? "
  premises_distance = gets.to_f
  print "How many splices between the ODF and premises #{number}? "
  premises_splices = gets.to_i
  print "how many connections between the ODF and premises #{number} (including ODF)? "
  premises_connections = gets.to_i
  return db_loss(premises_distance, wavelength, premises_splices, premises_connections)
end


###### Program ######

# Change the wavelength name if necessary.
unless wavelength == "a"
  wavelength_name = "1310nm"
end

# Establish how many connections there are going to be.
print "How many premises are we running fibre to? "
premises_amount = gets.to_i

# Get backbone details.
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


###### Print out the results ######
puts "" * 5
puts "We are using #{wavelength_name} SMOF to go to #{premises_amount} premises."
puts ""
puts "OLT to ODF loss is #{backbone_db_loss}."
puts ""
premises.each {|number, value| puts "premises #{number} has loss of #{value} dB."}
puts ""
puts "premises #{worst_case.keys.first} has the greatest loss (#{worst_case.values.first} dB) and a total loss of #{worst_case.values.first + backbone_db_loss} dB."

