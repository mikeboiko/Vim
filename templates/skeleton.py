#!/usr/bin/env python3.6
'''
'''

# Imports {{{1

import os        # OS functions
import sys       # System functions

# Variables {{{1

# Functions {{{1
def main(): # {{{2
    'Main script entry point'

# Main {{{1

# Run script if this file is executed directly
if __name__ == '__main__':
    main()

# This module is a way to identify ubuntu
if 'apport_python_hook' not in sys.modules:
    os.system('pause')
