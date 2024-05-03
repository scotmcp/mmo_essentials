# mmo_essentials
A collection of source based tools essential for networking games, especially MMOs and others with a very high concurrent user base.

These tools are intended to be used as classes or libraries of functions that you can copy and paste into your own projects.

Main Trunk
BittyBytes
is a base class of functions used to pack and unpack arrays of numeric
values into their smallest possible form, bits. This is especially desirable
for network games with dedicated servers expected to send and receive
a constant stream of data from many players.

Branches
ClockSynch - In development
Synchronize Clocks between server and players to facilitate the normalization of network latency, and to support better
interpolation and extrapolation (smooth action and prediction).
