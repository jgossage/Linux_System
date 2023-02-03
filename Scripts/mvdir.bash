# Script to move the contents of a directory to a new location
# If the move is sucessful, the source directory is deleted and a symbolic
# link to the new directory is created. This assumes that this script is being run
# from the directory that contains the original directory and that the symbolic
# link should be created in this directory.
# If the target directory already has content it will only be updated if the source
# is newer than the target. If the target does not contain the source, it is always
# updated.
# The command accepts a variable number of arguments specifting source directories to
# be moved, as well as the name of the target directory that is to receive the
# updates.

declare -r olddir=$("pwd")
declare currentdir="$olddir"
declare -a directories=() # The directories from the home directory that are being
                          # handled in this invocation

cleanup () {
  if [[ $olddir != $currentdir ]];
  then
    cd "$olddir" # Restore our previous directory
  fi
}

validate_command () {
  # This function checks the output of the command to ensure that every file got
  # properly copied and the the symbolic links are good.

  # Arguments
  #    src - The source directory from which a list of directories is being
  #          extracted.
  #    tgt - The target directory that will contain the extracted directories

  # Loop testing the existence of symbolic links that have been constructed
  # between the source directory and the target directory.
  declare -i ret=0 # test error code. Assume everything will work
  for dir in $directories;
  do
    [[ -h $dir ]] || (echo "Symbolic link not properly created for $dir"; ret=1;)
  done
  return $ret
}

movedir () {
  # Function to move a group of directories to the targetand create a symololic link
  # to it. The move is validated to ensure that the move was properly done before
  # the source directory is deleted and a symbolic link is created.

  # Arguments
  #    src - The source directory to move. This maybe a relative or absolute path
  #          to the directory to be moved. The last part of the path is the name of
  #          the source directory to be moved.
  #    tgt - The target directory to receive the move. This can be a relative or
  #          absolute path.
  #   dirs - The directories to be moved and linked. A series of positional arguments

  trap cleanup EXIT # Make sure that we can always get back to our original
                    # directory
                    echo "Entered movedir"
  declare -r src="$1" # get the source path                  
  declare -r tgt="$2" # Get the target path
  echo "Source path is - $src, target path is - $tgt"
  shift 2 # Leaves only directory names in the arguments
  declare -r backup_suffix='~'
  declare -r pcmd="cp --archive --backup=numbered --update --no-dereference --force --target-directory=$tgt"
  if [[ $olddir != $src ]];
  then
    cd "$src" # Position ourselves in the source directory if we are not already
              # there
  fi
  declare cmd="${pcmd}" # Start for building the final command

  # Loop doing the move for each specified directory
  for dir in "$@";
  do
    cmd+=" $dir" # Add this directory to the command
    directories+=("$dir") # Add it to the list of directories handled
  done

  # We need to execute the command and then check the
  # contents of each directory to make sure they were properly transferred
  echo -e "Final command is:\n   <$cmd>"
  $($cmd) # run the final command

  # Loop linking the moved source directories to their new location
  # with a symbolic link. Links in old locations
  echo "Directories being processed are: - <${directories[@]}>"
  for dir in ${directories[@]};
  do
    declare tdir="$tgt/$dir"
    declare sdir="$src/$dir"
    echo "Making link of $dir to $tdir in $sdir"
    sudo rm -R $sdir # Get rid of the source directory so we can create a link there
    ln -s "$tdir" $dir
    ret=$?
    (($ret != 0)) && echo "Return code from ln is $ret and we were trying to create symbolic link $dir in $src to $tgt/$dir"
  done
  # Validate the output from the command
  validate_command $src $tgt
  return $?
}

# Invoke the working function passing the command line arguments
declare -i retx=0
movedir $@
retx=$?
if (($retx != 0));
then
  echo "We should not have got here- return code $retx"
  exit 1
fi
exit 1
