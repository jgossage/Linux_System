# Link user directories to the appropriate shared directory so that they are not
# affected by reinstallation of the operating system. The directories to be saved 
# are defined in the array SavedDirs which is user modifiable

# Initialization that should be done before our functions are loaded
# so that these artifacts may be available to our functions

# Get the scripts that we use
source oscmd

# Initial variable definitions. The values of these variables will change as we
# find out more about what we are doing.
previous_directory=${pwd}
current_directory="$previous_directory"
source_directory="/tmp/bldptest" # Asssumes a testing environment
                                 # This directory is the directory we are
                                 # manipulating
destination="$source_directory/target" # Assumes a testing environment
                                       # This is where we are putting the contents
                                       # of the directories that we are moving
                                       # from the source directcory. When running
                                       # in production. this location can be
                                       # overridden by the script invoker.

cleanup () {
  # Cleans up the  environment - invoked on script exit via "trap cleanup EXIT"

  if [[ "$current_directory" -ne "$previous_directory" ]];
  then # Switch back to directory in use before running this script
    cmd "cd $previous_directory"
  fi
}

SaveDirs=('Documents' 'Downloads' 'Music' 'Pictures' 'Templates' 'Videos')

run () {
  declare -i ret=0

  # Loop handling the directories that we want to move
  for tgt in "${SaveDirs[@]}"
  do
    src="$source/$tgt"
    target="$destination/$tgt"
    [[ -d $target ]] && td=1 || td=0  # Flag if target directory already exists
    if [[ -e $src ]];
    then  # This should be a directory or symbolic link
      if [[ -d $src ]];
      then
        if [[ $(ls -A $src) ]];
        then
          cmd "sudo mv -uv $src $target" # Copy directory and contents
        else # Source directory is empty - just make a directory on target
          [[ $td -eq 0  ]] && cmd "sudo rmdir $src"; cmd "mkdir -pv $target"
        fi
      elif [[ -L $src ]];
      then
        cmd "mv -uv $src $target" # Copy symbolic link
      else
        cmd "echo testbldp: $target is not a directory or symbolic link"
        exit 2
      fi
      if [[ ! -e $target ]];
      then
        [[ $td -eq 0  ]] && cmd "mkdir -pv $target" # Create a missing target directory
      else # Make sure we got a directory as expected
        if [[ ! -d $target ]];
        then
          cmd echo "testbldp: Target directory $target not created. Got file instead"
          exit 2
        fi
      fi
    else  # Expected directory missing from source - just make empty directory
      [[ $td -eq 0  ]] && cmd "mkdir -pv '$target'"
    fi
    cmd "ln -s $target $tgt" # Symbolic link to the personal directory
  done
  return 0
}

parent=$(cat /proc/$PPID/comm)
if [[ $parent = '' ]];
then # Bldpersonal doing nothing because we were sourced and our caller is using the
     # run function to get things done. If something failed, the script was exited.
  return 0
else
  run # Run the script because we were invoked from the command line so there is no
      # parent to call run for us.
fi

exit 0