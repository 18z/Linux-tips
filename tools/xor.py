#!/usr/bin/python

import sys

if len(sys.argv) != 4:
  print "Usage: ./xor infile outfile k"
  print "k is a one-character XOR key"
  print "For hexadecimal keys, use $'\\x01'"
  exit()

f = open(str(sys.argv[1]), "rb")
g = open(str(sys.argv[2]), "a")
k = ord(sys.argv[3])

try:
    byte = f.read(1)
    while byte != "":
        xbyte = ord(byte) ^ k
        g.write(chr(xbyte))
        byte = f.read(1)
finally:
    f.close()

g.close()
