#!/bin/bash
RANGE=16
#set integer ceiling

numbera=$RANDOM
numberb=$RANDOM
numberc=$RANDOM
numberd=$RANDOM
numbere=$RANDOM
numberf=$RANDOM
#generate random numbers

let "numbera %= $RANGE"
let "numberb %= $RANGE"
let "numberc %= $RANGE"
let "numberd %= $RANGE"
let "numbere %= $RANGE"
let "numberf %= $RANGE"
#ensure they are less than ceiling

octets='BE-EF-00'
#set mac stem

octeta=`echo "obase=16;$numbera" | bc`
octetb=`echo "obase=16;$numberb" | bc`
octetc=`echo "obase=16;$numberc" | bc`
octetd=`echo "obase=16;$numberd" | bc`
octete=`echo "obase=16;$numbere" | bc`
octetf=`echo "obase=16;$numberf" | bc`
#use a command line tool to change int to hex(bc is pretty standard)
#they're not really octets.  just sections.

macadd="${octets}-${octeta}${octetb}-${octetc}${octetd}-${octete}${octetf}"
#concatenate values and add dashes

echo $macadd
