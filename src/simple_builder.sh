#!/bin/sh
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done
export PATH=$PATH:$(echo /var/task/*coreutils*/bin)
#echo -e "\0001"
#ls /proc/self/fd -alh
#ls /proc/*/fd/10 -alh
#T=$(ls /proc/*/fd/10)
#ls -alh $(dirname $T)
echo hello > $out
echo out is: $out
echo -e "Leaving"
#echo -e "\0001"
#echo -e "\0001Stuff"
#echo abacadabra > /dev/pts/ctrl
echo hi
exit 0
