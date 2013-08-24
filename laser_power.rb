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

# Methods

def db_loss(distance, splices, connections)
  return (distance.to_f * 0.35) + (splices.to_f * 0.10) + (connections.to_f * 0.30)
end


# Establish how many connections there are going to be
print "How many premises are we running fibre to? "
premises = gets.chomp()

# get backbone details
print "What is the distance from the OLT to the ODF (in KM's)? "
backbone = gets.chomp()
print "How many splices between OLT and ODF? "
backbone_splices = gets.chomp()
print "How many connections are between the OLT and ODF? "
backbone_connections = gets.chomp()

backbone_db_loss = db_loss(backbone, backbone_splices, backbone_connections) + 0.30 + 19





