#!/usr/bin/env python3.6
'''
'''
# dev: let b:start = ""
# dev: let b:startapp = "./"
# dev: let b:startfile = @%

# Imports {{{1

import os        # OS functions
import sys       # System functions

# Arguments {{{1

# Title
parser = argparse.ArgumentParser(__doc__)

# Positional arguments
parser.add_argument(
        dest='dictFile',
        action='store',
        help='Name of dictionary csv list'
        )
parser.add_argument(
        dest='inputFile',
        action='store',
        help='Name of original text file, where replacements are to occur'
        )

# Optional arguments
parser.add_argument(
        '-o',
        '--outputFile',
        dest='outputFile',
        action='store',
        default='output.txt',
        help='Name of output file (default is output.txt)'
        )

# Boolean arguments
parser.add_argument(
        '--dos',
        dest='dos_line_ending',
        action='store_true',
        help='Specify if this is a dos line ending (default is Unix)'
        )

# Perform parsing
args = parser.parse_args()

# Variables {{{1

# Functions {{{1
def main(): # {{{2
    'Main script entry point'

# Main {{{1

# Run script if this file is executed directly
if __name__ == '__main__':
    main()
