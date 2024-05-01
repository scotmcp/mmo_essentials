# mmo_essentials
A collection of source based tools essential for networking games, especially MMOs and others with a very high concurrent user base.

These tools are intended to be used as classes or libraries of functions that you can copy and paste into your own projects.

Index
BittyBytes - is a base class of functions used to pack and unpack arrays of numeric
values into their smallest possible form, bits. This is especially desirable
for network games with dedicated servers expected to send and receive
a constant stream of data from many players. Under normal circumstances
using Godot's High Level Multiplayer API will require somewhere between 15-20 bytes
of overhead for each variable to "address" the variable inside the network
datagram. By converting larger formats of variable into smaller formats,
we can minimize the amount of datagram overhead needed to send a group of tiny
pieces of information. This is most beneficial for multiplayer games that
have a high number of players, network games that are commonly called
MMOs or Massively Multiplayer Online Games.
