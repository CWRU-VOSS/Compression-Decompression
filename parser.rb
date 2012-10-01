#Title: Ruby DNA Decompression Script
#Author: Omri Shiv
#Version: .01
#Details: 
#Usage: ruby parser.rb SequenceFile.csv ClustalFile.lg1


# declarations
uniqueSeqArray = Array.new # Array for holding the unique sequence position
uniqueArrayPos = 1 # Array position counter starts at 1 to match sequence 1 from file
allSeqArray = Array.new # Array for holding all sequences
allArrayPos = 1 # Array position counter for all sequence array
seqHash = Hash.new # Hash for holding frequency of sequences
effortCounter = 0.0 # Used for calculating Average Effort
transitions = 0 # Counts the actual number of transitions

#We first build an array for all of our unique sequences
seqFile = File.open(ARGV[0])
seqFile.each do |u|
	if !u.match(/>/) #only look at sequences, not sequence names
		allSeqArray[allArrayPos] = u
		allArrayPos += 1
		if !uniqueSeqArray.include?(u) # sequence has not occured yet
			uniqueSeqArray[uniqueArrayPos] = u # we need to add it into the array
			uniqueArrayPos += 1
		end
	end
end

#We now need to build a hash that gives us easy lookup of the sequence comparissons
clustalFile = File.open (ARGV[1])
clustalFile.each do |u|
	if u.match(/Sequences /)
		pid = u.match(/%id: {0,4}[0-9]{0,3}/)[0].gsub(/%id: {0,4}/,'') # find %id and chop off excess
		seqs = u.match(/s[0-9]{0,5} s[0-9]{0,5}/)[0].split(/ /) # split the seqs into an array of 2 sequences
		seq1 = uniqueSeqArray[seqs[0].gsub(/s/, '').to_i] #lookup the first sequence
		seq2 = uniqueSeqArray[seqs[1].gsub(/s/, '').to_i] #lookup its pair

		#here comes the fun part. Create hashes for all sequence lookups with %ID of each pair
		seqHash[seq1] = Hash.new if not seqHash.key?(seq1)
		seqHash[seq2] = Hash.new if not seqHash.key?(seq2)
		seqHash[seq1][seq2] = pid
		seqHash[seq2][seq1] = pid
	end
end

# Now we have an easy way to look up every comparisson's %id. Let's build us a table
compareFile = File.new('comparefile.csv', 'w+')
arrayIterator = 1
while !allSeqArray[arrayIterator].nil?
	s1Pos = arrayIterator
	s2Pos = s1Pos + 1	
	innerIterator = s2Pos 
	while !allSeqArray[s2Pos].nil?
		pid = seqHash[allSeqArray[s1Pos]][allSeqArray[s2Pos]]
		pid = 100 if pid.nil? # HACK. This needs to be fixed.
		s1Act = allSeqArray[s1Pos]
		s2Act = allSeqArray[s2Pos]
		compareFile << "#{s1Pos}, #{s2Pos}, #{pid}, #{s1Act[0,3]}#{s2Act[0,3]}\n"
		s2Pos += 1
	end
	arrayIterator += 1
end

# Alright, let's make some matrices (I hate arrays in Ruby so I'm not going to use them...)
fullMatrix = File.new('fullmatrix.csv', 'w+')
fullMatrix <<" , "

(1..allSeqArray.count-1).each do |i| # header
	fullMatrix << "s#{i}, "
end

fullMatrix << "\n"

(1..allSeqArray.count-1).each do |i|
	row = ""
	(1..allSeqArray.count-1).each do |u|
		if seqHash[allSeqArray[i]].nil? || seqHash[allSeqArray[i]][allSeqArray[u]].nil?
			pid = 100 
		else
			pid = seqHash[allSeqArray[i]][allSeqArray[u]]
		end
		
		row << ", #{pid} "
		
		if u == i+1 # calculating effort
			effortCounter += 1-(seqHash[allSeqArray[i]][allSeqArray[u]].to_f)/100
			transitions += 1
		end
		
	end
	fullMatrix << "s#{i} #{row} \n"
end

puts "Total Effort = #{effortCounter}\n"
puts "Average Effort = #{effortCounter/transitions}"