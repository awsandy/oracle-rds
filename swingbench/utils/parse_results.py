from __future__ import print_function

import argparse
import os
import re
import sys
import glob
import xml.etree.ElementTree as ET
from collections import OrderedDict

from prettytable import PrettyTable, NONE


def get_namespace(element):
    m = re.match('\{.*\}', element.tag)
    return m.group(0) if m else ''


def get_tx_results(doc, namespace, tx_type, tx_id):
    attrib = doc.find(".//*{0}Result[@id='{1}']/{0}{2}".format(namespace, tx_id, tx_type))
    if attrib is not None:
        return attrib.text
    else:
        return '0'


def print_csv(table):
    table.border = True
    table.vertical_char = ','
    table.junction_char = ' '
    table.horizontal_char = ' '
    table.hrules = NONE
    table.padding_width = 0
    table_string = x.get_string()
    new_line = re.sub('^,', '', re.sub('(,\n,)|(,$)', '\n', table_string.rstrip()))
    print(new_line, end='')


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Swingbench results file processor')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-r", "--resultfile", help="The name of the resultfile to parse", required=False, nargs='*')
    group.add_argument("-d", "--dir", help="wildcard string for directory containing result files", required=False)
    parser.add_argument("-o", "--outputfile", help="File to store comma separated results (defaults to stdout")
    parser.add_argument("-c", "--csv", help="Output results as csv", action='store_true')
    args = parser.parse_args()

    if args.resultfile is not None:
        xmlfiles = args.resultfile
    else:
        xmlfiles = glob.glob(args.dir)

    outFileName = args.outputfile

    if outFileName is None:
        output = sys.stdout
    else:
        output = open(outFileName, 'w')

    xmldocs = {}
    transactions = set()

    x = PrettyTable()

    for fileToParse in xmlfiles:
        tree = ET.parse(fileToParse)
        root = tree.getroot()
        namespace = get_namespace(root)
        xmldocs[os.path.basename(fileToParse)] = root
        # get a list of unique transactions
        transactions.update([tx_id.attrib.get('id') for tx_id in root.findall('.//{0}Result'.format(namespace))])

    # sort all of the files so we can search them consistently
    sortedxmldocs = OrderedDict(sorted(xmldocs.items()))
    x.field_names = ['Attribute'] + list(sortedxmldocs)
    x.align['Attribute'] = 'l'

    get_result = (lambda section, tag: [doc.find('.//{0}{1}/{0}{2}'.format(namespace, section, tag)).text or ' ' for doc in sortedxmldocs.values()])

    benchmark_names = get_result('Overview', 'BenchmarkName')
    x.add_row(['Benchmark Name'] + benchmark_names)
    connect_strings = get_result('Configuration', 'ConnectString')
    x.add_row(['Connect String'] + connect_strings)

    time_of_run = get_result('Overview', 'TimeOfRun')
    x.add_row(['Time of run'] + time_of_run)
    min_inter_think = get_result('Configuration', 'MinimumInterThinkTime')
    x.add_row(['Minimum Inter TX Think Time'] + min_inter_think)
    max_inter_think = get_result('Configuration', 'MaximumInterThinkTime')
    x.add_row(['Maximum Inter TX Think Time'] + max_inter_think)
    min_intra_think = get_result('Configuration', 'MinimumIntraThinkTime')
    x.add_row(['Maximum Intra TX Think Time'] + min_intra_think)
    max_intra_think = get_result('Configuration', 'MaximumIntraThinkTime')
    x.add_row(['Maximum Intra TX Think Time'] + max_intra_think)
    no_users = get_result('Configuration', 'NumberOfUsers')
    x.add_row(['No of Users'] + no_users)
    total_run_times = get_result('Overview', 'TotalRunTime')
    x.add_row(['Total Run Time'] + total_run_times)
    avg_tx_per_sec = get_result('Overview', 'AverageTransactionsPerSecond')
    x.add_row(['Average Tx/Sec'] + avg_tx_per_sec)
    max_tx_per_min = get_result('Overview', 'MaximumTransactionRate')
    x.add_row(['Maximum Tx/Min'] + max_tx_per_min)
    completed_tx = get_result('Overview', 'TotalCompletedTransactions')
    x.add_row(['Total Completed Transactions'] + completed_tx)

    get_tx_result = (lambda tx_type, tx_id: [get_tx_results(doc, namespace, tx_type, tx_id) for doc in sortedxmldocs.values()])
    format_numbers = (lambda x_val: '{0:.2f}'.format(float(x_val)))

    x.add_row([''] * (len(sortedxmldocs) + 1))
    x.add_row(['Average Transaction Response Time'] + [''] * (len(sortedxmldocs)))
    for transaction in transactions:
        tx_results = get_tx_result('AverageResponse', transaction)
        x.add_row([transaction] + list(map(format_numbers, tx_results)))

    x.add_row([''] * (len(sortedxmldocs) + 1))
    x.add_row(['10th Percentile Transaction Response Time'] + [''] * (len(sortedxmldocs)))
    for transaction in transactions:
        tx_results = get_tx_result('TenthPrecentile', transaction)
        x.add_row([transaction] + list(map(format_numbers, tx_results)))

    x.add_row([''] * (len(sortedxmldocs) + 1))
    x.add_row(['50th Percentile Transaction Response Time'] + [''] * (len(sortedxmldocs)))
    for transaction in transactions:
        tx_results = get_tx_result('FiftythPercentile', transaction)
        x.add_row([transaction] + list(map(format_numbers, tx_results)))

    x.add_row([''] * (len(sortedxmldocs) + 1))
    x.add_row(['90th Percentile Transaction Response Time'] + [''] * (len(sortedxmldocs)))
    for transaction in transactions:
        tx_results = get_tx_result('NinetiethPercentile', transaction)
        x.add_row([transaction] + list(map(format_numbers, tx_results)))

    if args.csv:
        print_csv(x)
    else:
        print(x)
