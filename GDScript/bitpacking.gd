extends Node
## This class is used to pack larger variable formats into smaller
## and to unpack them when needed. This is especially desirable
## for network games with dedicated servers expected to send and receive
## a constant stream of data from many players. Under normal circumstances
## using Godot's High Level Multiplayer API will require approximately 15-20 bytes
## of overhead for each variable to "address" the variable inside the network
## datagram. By converting larger formats of variable into smaller formats,
## we can minimize the amount of overhead needed to send a group of tiny
## pieces of information. This is most beneficial for multiplayer games that
## have a high number of players, network games that are commonly called
## MMOs or Massively Multiplayer Online Games.

## Sets the class_name so this script is available globally.
class_name BittyBytes

## Convert an array of bools to an int
func array2int32(array) -> int:
	var buffer : int = 0
	for state in array:
		buffer = buffer << 1
		buffer += state
	return buffer

## Convert an integer into an array of bools in the same order that the
## integer was packed or First In First Out.
## This is much slower than 'byte2lifoarray'.
func byte2fifoarray(byte) -> Array:
	var array = []
	if byte:
		while byte > 0:
			array.push_front(byte &0x01)
			byte = byte >> 1
	return array

## Convert an integer into an array of bools in the reverse order that the
## integer was packed or Last In First Out.
## This is much faster than 'byte2fifoarray'
func byte2lifoarray(byte) -> Array:
	var array = []
	if byte:
		while byte > 0:
			array.append(byte &0x01)
			byte = byte >> 1
	return array
