# script to test combining local variable definitions
declare -r a='a'
declare -r b='b'
declare -r c='c'
declare -r d='d'
declare -A args=([$a]='aaa' [$b]='bbb' [$c]='ccc' [$d]='ddd')
# For every key in the associative array.
echo "Keys are ${!args[@]}"
echo "Values are: ${args[@]}"
for KEY in "${!args[@]}"; do
  # Print the KEY value
  echo "Key: $KEY, value: ${args[$KEY]}"
done
echo "A value is: ${args[a]}"
j=0
k=1
l=2
((j!=k && j < l)) && echo 'Yes arithmetic' || echo 'No arithmetic'
m=''
n='n'
o='something'
other='something else'
[[ -e m  && $n == 'n' && $o == 'something else' ]]\
    && echo 'Yes string' || echo 'No string'
[[ -e $o ]] && echo 'O exists' || echo 'O does not exist'
[[ -e other ]] && echo 'Other exists' || echo 'Other does not exist'
echo "$o"