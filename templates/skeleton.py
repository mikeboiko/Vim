#!/usr/bin/env python
'''
'''
# dev: let b:startapp = "./"
# dev: let b:startfile = @%
# dev: let b:startargs = "test"

# Imports {{{1

import argparse

# Arguments {{{1

# Parse CLI arguments
parser = argparse.ArgumentParser(
    description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

# Positional arguments
parser.add_argument(dest='dictFile', action='store', help='Name of dictionary csv list')

# Optional arguments
parser.add_argument(
    '-o',
    '--outputFile',
    dest='outputFile',
    action='store',
    default='output.txt',
    help='Name of output file (default is output.txt)')

# Boolean arguments
parser.add_argument(
    '--dos',
    dest='dos_line_ending',
    action='store_true',
    help='Specify if this is a dos line ending (default is Unix)')

# Variables {{{1

class MyClass():  # {{{1
    '''
    '''

    def __init__(self, **kwargs):  # {{{2
        '''
        Initialize all the variables
        '''
        pass

# Functions {{{1
def main():  # {{{2
    'Main script entry point'
    pass

# Main {{{1

# Run script if this file is executed directly
if __name__ == '__main__':
    args = parser.parse_args()
    main()
