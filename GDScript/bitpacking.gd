class_name BittyBytes
## Pack and unpack arrays to and from integers
##
## BittyBytes is a base class of functions used to pack and unpack arrays of numeric
## values into their smallest possible form, bits. This is especially desirable
## for network games with dedicated servers expected to send and receive
## a constant stream of data from many players. Under normal circumstances
## using Godot's High Level Multiplayer API will require somewhere between 15-20 bytes
## of overhead for each variable to "address" the variable inside the network
## datagram. By converting larger formats of variable into smaller formats,
## we can minimize the amount of datagram overhead needed to send a group of tiny
## pieces of information. This is most beneficial for multiplayer games that
## have a high number of players, network games that are commonly called
## MMOs or Massively Multiplayer Online Games.
## See [BittyBytes.pack] and [BittyBytes.unpack] for detailed descriptions.


## BittyBytes pack class is a group of functions to pack values into integer.
##
## The pack class class is used to take an array of fixed length values
## (ex. all booleans or all octets) and pack them into an integer. You can store
## smaller that the defined value, but this will create leading zeros.
## (example. using octets to store a boolean will result in 3 bits used to store the
## value 001) However this is better than using an entire 64 bit integer and
## associated additional 15 to 20 bytes network overhead for each integer variable.
## These packed integers are normally unpacked using the associated [BittyBytes.unpack] functions.
class pack: 
	
	## The source array containing the values to pack.
	var array : Array[int] = [0]

	## Packs an array of booleans (0 or 1) and returns an integer. The maximum number of bools that can be
	## packed into a single int is 64.
	func bools(array : Array) -> int:
		var buffer : int = 0
		for element in array:
			buffer = buffer << 1
			buffer += element
		return buffer


	## Packs an array of triplets (0 to 2) and returns an integer. The maximum number of triplets
	## that can be stored in an int is 32.
	func triplets(array : Array) -> int:
		var buffer : int = 0
		for element in array:
			buffer = buffer << 2
			buffer += element
		return buffer
		
		
	## Packs an array of octets (0 to 7) and returns an integer. The maximum number of octets
	## that can be stored in an int is 21.
	func octets(array : Array) -> int:
		var buffer : int = 0
		for element in array:
			buffer = buffer << 3
			buffer += element
		return buffer

	## Packs an array of nibbles (0 to 15) and returns an integer. The maximum number of octets
	## that can be stored in an int is 16.
	func nibbles(array : Array) -> int:
		var buffer : int = 0
		for element in array:
			buffer = buffer << 4
			buffer += element
		return buffer
		
	## Packs an array of bytes (0 to 255) and returns an integer. The maximum number of octets
	## that can be stored in an int is 8.
	func byte(array : Array) -> int:
		var buffer : int = 0
		for element in array:
			buffer = buffer << 8
			buffer += element
		return buffer
		
		
## Functions to unpack values from integars into an array. This is normally
## performed on an array that has been packed using the provided [BittyBytes.pack] functions.
class unpack:
	
	## Default
	var reverse : bool = true
	
	## The source integer containing the packed values to unpack.
	var integer : int = 0
	
	
	## Unpack an integer into an array of bools.
	func bools(integer : int, reverse : bool) -> Array:
		var array : Array[int]
		if integer:
			while integer > 0:
				if reverse:
					array.append(integer &0x01)
				else:
					array.push_front(integer &0x01)
				integer = integer >> 1
		return array



	## Unpack triplets (0-2) from an array of triplets.
	func triplets(integer : int, reverse : bool) -> Array:
		var array : Array[int]
		if integer:
			while integer > 0:
				if reverse:
					array.append(integer &0x03)
				else:
					array.push_front(integer &0x03)
				integer = integer >> 2
		return array


	## Unpack octets (0-7) from an array of octects.
	func octets(integer : int, reverse : bool) -> Array:
		var array : Array[int]
		if integer:
			while integer > 0:
				if reverse:
					array.append(integer &0x07)
				else:
					array.push_front(integer &0x07)
				integer = integer >> 3
		return array
		
	## Unpack bytes (0 to 15) from an array of octects.
	func bytes(integer : int, reverse : bool) -> Array:
		var array : Array[int]
		if integer:
			while integer > 0:
				if reverse:
					array.append(integer &0x0f)
				else:
					array.push_front(integer &0x0f)
				integer = integer >> 3
		return array
		
	## @experimental
	## Use at your own risk, this function is still in development and testing.
	func unpackvarious(byte : int, bits_per_element : int, num_elements : int, lifo : bool) -> Array:
		# Generate a mask with the correct number of bits per element.  For example, 0x111 for 3 bits per element.
		var mask = (0x01 << bits_per_element) - 1
		
		# Initialize the starting position within the byte.
		var position = 0
		if !lifo:
			position = bits_per_element * (num_elements - 1)
		
		# How much will we increment the position when we loop?
		var increment = bits_per_element
		if !lifo:
			increment = -increment
		
		var array = []
		for i in num_elements:
			var element = (byte >> position) & mask
			array.append(element)
			position += increment
		return array
