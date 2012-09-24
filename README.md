Compression-Decompression
=========================

This is a DNA decompression script to augment the process analysis we perform. 


Usage
=========================

To use this script, type the following in a terminal window (assuming all files are in the current working directory):

> ruby parser.rb SequenceFile.csv ClustalFile.lg1

Where parser.rb is this script, SequenceFile.csv is the file containing all sequences to be decompressed, and ClustalFile.lg1 is the output file from Clustal showing all sequencing of only the unique sequences

The script will output a comparefile.csv which has 4 columns. The first two are the two sequences being compared, the next column is the %id similarity between the sequences, the last is a combination of the first 3 letters of the first sequence's activity type and the first 3 letters of the next sequence's activity type. 