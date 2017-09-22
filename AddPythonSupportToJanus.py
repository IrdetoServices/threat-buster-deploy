import yaml

import argparse

parser = argparse.ArgumentParser(description='Add python support to Gremlin config file')
parser.add_argument("file", help="The input file")
parser.add_argument("-o", "--output", help="The output file")
args = parser.parse_args()

if args.output:
    outputFile = args.output
else:
    outputFile = "modified.{}".format(args.file)

with open(args.file, 'r') as stream:
    try:
        config = yaml.load(stream)

        if not 'gremlin-jython' in config['scriptEngines']:
            config['scriptEngines']['gremlin-jython'] = {}
            print("Adding gremlin-jython")

        if not 'gremlin-python' in config['scriptEngines']:
            config['scriptEngines']['gremlin-python'] = {}
            print("Adding gremlin-python")

        with open(outputFile, 'w') as outputStream:
            yaml.dump(config, outputStream)

    except yaml.YAMLError as exc:
        print(exc)
