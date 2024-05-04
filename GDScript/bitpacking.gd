class_name BittyBytes
## Pack and unpack arrays of integers.
##
## BittyBytes is a class of functions used to pack and unpack arrays of numeric
## values into their smallest possible form, bits. This is especially desirable
## for network games with dedicated servers expected to send and receive
## a constant stream of data from many players. Under normal circumstances
## using Godot's High Level Multiplayer API will require somewhere between 15-20 bytes
## of overhead for *each* variable to "address" the variable inside the network
## datagram. Additionally, a boolean (true or false) is still considered an integer
## and requires the entire 64 bit word length to be stored or processed.
## By converting large groups of numeric variables into one single integer,
## eliminating the waste of lots and lots of uneeded leading zeros per boolean we can we can minimize 
## the amount of network datagram overhead needed while constantly streaming large numbers of
## tiny pieces of information in both directions. This is most beneficial for multiplayer games that
## have a high number of players, network games that are commonly called
## MMOs or Massively Multiplayer Online Games.



## Return an integer packed with smaller integers. Recommended for bitpacking values of 8 bits or less.
## Normally meant to be extracted by the counter part [unpack] function. Default bit_length = 1 or bool.
func pack(array : Array[int], bit_length : int = 1) -> int:
	# Initialize buffer with a single starting bit = 1 to tell unpack() when to stop
	var buffer : int = 1
	for value in array:
		buffer = buffer << bit_length
		buffer += value
	return buffer



## Functions to unpack values from integers into an array of integers.
## This is normally performed on a packed integer created by using the
## provided by counter part [pack] function. The returned Array elements will be
## ordered in reverse order from the originating array.
##
## Default bit_length = 1 or bool.
func unpack(integer : int, bit_length : int = 1) -> Array:
	var mask : int = 0
	var array : Array[int]
	for i in bit_length:
		mask = mask << 1
		mask += 1
	if integer:
		# Unpack values, and stop when 1 has been reached.
		while integer > 1:
			array.append(integer &mask)
			integer = integer >> bit_length
	return array


