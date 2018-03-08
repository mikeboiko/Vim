# =======================================================================
# === Description ...: 
# === Author ........: Mike Boiko
# =======================================================================

# Imports {{{1

import argparse  # Parse CLI arguments
import os        # OS functions
import sys       # System functions

# Arguments {{{1

parser = argparse.ArgumentParser(description='Find/Replace Multiple Occurences')

parser.add_argument(dest='dictFile', action='store',
                    help='Name of dictionary csv list')
parser.add_argument(dest='inputFile', action='store',
                    help='Name of original text file, where Replacements are to occur')

parser.add_argument('-of', '--outputFile', dest='outputFile', action='store',
                    default='output.txt',
                    help='Name of xlsx worksheet - default is 1st sheet')

# Parse all arguments
args = parser.parse_args()

# Functions {{{1

# Main {{{1

