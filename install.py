#!/usr/bin/python
import os
'''
Parses the Readme.md file and installs/copies shit over.
'''

infile = "./Readme.md"
def install_packages():
    print "Installing packages..."
    f = open(infile, 'r')
    for line in f:
        if 'install: ' in line:
            # This is a list of packages to install. Probably.
            toinstall = line.partition('`')[2].replace('`', '')
            os.system('sudo apt-get install ' + toinstall)
    f.close()

#TODO: Copy hidden directories and files to home.
def copy_dotfiles():
    print "Moving dotfiles..."
    files_in_curdir = []
    for root, dirs, files in os.walk('./'):
        if '.git' in dirs:
            dirs.remove('.git')
        files_in_curdir = files
        break

    for f in files_in_curdir:
        if f[0] == '.':
            print f
            #TODO: Actually copy the files to ~/.

#TODO: Run any scripts in this directory.
def run_scripts():
    pass

if __name__ == "__main__":
    #install_packages()
    #copy_dotfiles()
    #run_scripts()
