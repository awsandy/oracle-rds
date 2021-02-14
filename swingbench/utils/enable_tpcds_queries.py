from __future__ import print_function

import argparse
import os
import re
import xml.etree.ElementTree as ET
import traceback


def get_namespace(element):
    m = re.match('\{.*\}', element.tag)
    return m.group(0) if m else ''


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Enable/Disable TPCDS queries')
    parser.add_argument("-c", "--config", help="The pathname of the tpcds_statements.xml file", required=True, nargs='*')
    parser.add_argument("-s", "--statement", help="The name of the query")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-ea", "--enable_all", help="Enable all the statements", action='store_true', dest='enable_all')
    group.add_argument("-da", "--disable_all", help="Disable all the statements", action='store_false', dest='enable_all')
    group.add_argument("-e", "--enable", help="Enable statement", action='store_true', dest='set_status')
    group.add_argument("-d", "--disable", help="Disable statement", action='store_false', dest='set_status')
    args = parser.parse_args()

    xmlfile = args.config[0]

    transactions = set()

    file = open(xmlfile, 'r')
    tree = ET.parse(file)
    root = tree.getroot()
    namespace = get_namespace(root)

    if args.statement is None:
        search_string = ".//{0}{1}/{0}enabled".format(namespace, 'SQLStatement')
        find_all_enabled = root.findall(search_string)
        for element in find_all_enabled:
            element.text = str(args.enable_all).lower()
        print("Set all statements enabled to {}".format(str(args.enable_all).lower()))
    else:
        try:
            found_enabled = root.find(".//{0}{1}[{0}name='{2}']/{0}enabled".format(namespace, 'SQLStatement', args.statement))
            found_enabled.text = str(args.set_status).lower()
            print("Query {} has had it's enabled status set to {}".format(args.statement, args.set_status))
        except Exception as e:
            print("Failed to enable/disable {}".format(args.statement))
            print(traceback.format_exc())

    file.close()
    tree = ET.ElementTree(root)

    os.rename(xmlfile, xmlfile + '.bak')
    file = open(xmlfile, 'w')
    tree.write(xmlfile,
               xml_declaration=True, encoding='utf-8',
               method="xml", default_namespace='http://www.dominicgiles.com/swingbench/SQLStatements')
