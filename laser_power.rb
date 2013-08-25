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

# Create hashes.
premises = Hash.new
worst_case = Hash.new

# Create counters.
premises_counter = 1
worst_case_counter = 0

# Methods
def db_loss(distance, splices, connections)
  # Perform calculations for 1310nm SMOF
  return (distance * 0.35) + (splices * 0.10) + (connections * 0.30)
end

# Ask questions for each premises.
def premises_query(number)
  # Get premises details and put them into 'premises' hash.
  print "What is the fibre distance (in KM's) from the ODF to premises number #{number}? "
  premises_distance = gets.to_f
  print "How many splices between the ODF and premises number #{number}? "
  premises_splices = gets.to_i
  print "how many connections between the ODF and premises number #{number}? "
  premises_connections = gets.to_i
  return db_loss(premises_distance, premises_splices, premises_connections)
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

backbone_db_loss = db_loss(backbone_distance, backbone_splices, backbone_connections) + 0.30 + 19

# Calls the premises query
while premises_counter <= premises_amount
  premises["#{premises_counter.to_s}"] = premises_query(premises_counter)
  premises_counter += 1
end

# Work out which premises has the highest loss
premises.each do |number, value|
  unless value < worst_case_counter
    worst_case_counter = value
    worst_case = {"#{number.to_s}" => value}
  end
end

# Print out the results
puts "OLT to ODF loss is #{backbone_db_loss}."
premises.each {|number, value| puts "premises #{number} has loss of #{value} dB."}
puts "premises #{worst_case.keys.first} has the greatest loss (#{worst_case.values.first} dB) and a total loss of #{worst_case.values.first + backbone_db_loss} dB."

