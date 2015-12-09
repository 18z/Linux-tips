#!/bin/bash

iptables -F;iptables -X;iptables -Z
iptables -F -t nat;iptables -X -t nat;iptables -Z -t nat
iptables -F -t mangle;iptables -X -t mangle;iptables -Z -t mangle

