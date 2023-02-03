#!/bin/bash
# This is the test driver for the bldpersonal script
source bldPersonal # Gives us access to the global variables defined in bldpersonal

testSetup () { # Setup the test environment
               # The main job is to create a test database and output directoy
               # to ensure that no production data gets clobbered as the bldpersonal
               # script modifies the source directory which is the home directory
               # in a production environment.


  declare -i testing=0
  if [[ $# -ne 0 ]];
  then # We are not testing so the source  directory should be our Home directory
    source_directory="$HOME"
    destination="$1" # The first command line argument is the backup directory
                     # that we want to use. 
  fi
  if [[ -e $source_directory ]] && [[ $source_directory != "$HOME"] ];
  then # We have a directory that is not our Home directory
    if [[ -d $source_directory ]];
    then # Source directory already exists - get rid of it so we can create a
         # new one with up-to-date content. Skip our Home directory which would be
         # a disaster if deleted.
      cmd "sudo rm -R $source_directory"
    else # This is not a directory - complain
      echo "testbldp: $source_directory is not a directory and we need one"
      exit 2
    fi
  fi
  # Source directory is empty or is our Home directory.
  # Create a backup of the Home directory.
  # This is done since the test is destructive and we don't want to test on live
  # data.
    
  # Copy the contents of the home directory to the source directory
  echo "testbldp: Please be patient because building a safe test environment could take around 10 min."
  echo "testbldp: Depending on what you were doing previously. you may be prompted for an administrator password."
  echo "testbldp: This is because several commands being run internally need sudo access."
  cmd "sudo cp -Ru --preserve=all $HOME $source_directory"
  
  cmd "mkdir -p $destination" # Works even when the target exists for both
                              # production and testing

  # Change directory into the testing source directory because we are using the ln
  # command to create symbolic links and it always puts the links that it creates
  # into the current directory
  if [[ $previous_directory != $source_directory ]];
  then
    cmd "cd $source_directory"
    current_directory="$source_directory"
  fi

  # Get the user's permission to continue
  echo "testbldp: We are testing bldpersonal and have setup the testing environment"
  echo -e "    Source directory is: $source_directory"
  echo -e "    Destination directory is $destination\n"
  read -p "    Does everything look OK and can we continue? y/n: " go
  [[ $go -eq 'n' ]] && exit 3
  return 0
}

cleanup () {
  # Assumes that bldpersonal has switched back to the original current directory
  # of the user because it is likely that the directory we are removing
  # was the current directory during script execution
  if [[ $source_directory != $current_directory]];
  then
    cmd "sudo rm -R $source_directory"
    source_directory=""
  fi
  return 0   
}

testValidate () {
  # This code makes sure that all the required symbolic links exist
  # and then compares all the files in the target directory against the
  # corresponding files in the sourcee directory, (a copy of the Home directory
  #) to ensure that they have been properly# copied and that there are no missing
  # files. The copy of the Home directory still exists at this time so the check
  # can be done easily.
  return 0 # Do nothing
}

# This code runs after bldpersonal has been sourced
trap cleanup EXIT # Runs cleanup whenever we exit the script. Works when exiting
                  # from bldpersonal even though it has its own exit function.

testSetup # Setup the testing environment
run # Runs the test by running bldpersonal
testValidate # Validate the execution
exit 0