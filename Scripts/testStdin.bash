echo "Header message"
while read line;
do
  echo "    ${line}"
  # Done should capture stdin, I think
done < /dev/stdin