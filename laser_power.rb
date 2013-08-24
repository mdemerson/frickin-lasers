# Works out the power required for the fricken laser beams
# as per the Australian NBN standards.
#
# 0.35 dB loss per kilometre
# 0.10 dB loss per fusion splice
# 0.30 dB loss per connection
# 19 dB loss at 32 way splitter (ODF)
#
# -8  dBm = max light reading
# -18 dBm = optimal light reading
# -28 dBm = minimal light reading
#
# Mathew Emerson - 24/08/13

# Create array for premises
premises = Hash.new
premises_counter = 1

# Methods

def db_loss(distance, splices, connections)
  return (distance.to_f * 0.35) + (splices.to_f * 0.10) + (connections.to_f * 0.30)
end

def premises_query(number)
  # Get premises details and put them into 'premises' hash.
  print "What is the fibre distance (in KM's) from the ODF to premises number #{number}? "
  premises_distance = gets.chomp()
  print "How many splices between the ODF and premises number #{number}? "
  premises_splices = gets.chomp()
  print "how many connections between the ODF and premises number #{number}? "
  premises_connections = gets.chomp()
  #@premises["#{number.to_s}"] = db_loss(premises_distance, premises_splices, premises_connections)
  return db_loss(premises_distance, premises_splices, premises_connections)
end


# Establish how many connections there are going to be.
print "How many premises are we running fibre to? "
premises_amount = gets.to_i

# Get backbone details.
print "What is the distance from the OLT to the ODF (in KM's)? "
backbone_distance = gets.chomp()
print "How many splices between OLT and ODF? "
backbone_splices = gets.chomp()
print "How many connections are between the OLT and ODF? "
backbone_connections = gets.chomp()

backbone_db_loss = db_loss(backbone_distance, backbone_splices, backbone_connections) + 0.30 + 19

while premises_counter <= premises_amount
  premises["#{premises_counter.to_s}"] = premises_query(premises_counter)
  premises_counter += 1
end

# Print out the results
puts "OLT to ODF loss is #{backbone_db_loss}."
premises.each { |number, value| puts "premises #{number} has loss of #{value}."}



