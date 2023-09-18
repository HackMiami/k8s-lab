import configparser
import argparse
import os
import sys


argparser = argparse.ArgumentParser(description='Create a new ansible config file')
argparser.add_argument('-f', '--file', help='The file to create or edit', required=True)
argparser.add_argument('-e', '--edit', action='store_true', help='Edit the file after creation')
argparser.add_argument('-k', '--key', help='key', required=True)
argparser.add_argument('-v', '--value', help='value', required=True)
argparser.add_argument('-s', '--section', help='section', default='default')
args = argparser.parse_args()

# Create a new INI file
config = configparser.ConfigParser()

if os.path.isfile(args.file):
    if args.edit:
        config.read(args.file)
        # check if there is a section
        if not config.has_section(args.section):
            config.add_section(args.section)
        config.set(args.section, args.key, args.value)

        with open(args.file, 'w') as configfile:
            config.write(configfile)
        sys.exit(0)
    else:
        print("File already exists. Use -e to edit")
        sys.exit(1)
else:
    config.add_section(args.section)
    config.set(args.section, args.key, args.value)
    with open(args.file, 'w') as configfile:
        config.write(configfile)
    sys.exit(0)
