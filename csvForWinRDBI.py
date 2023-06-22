'''
This is a simple Python program to assist in generating a csv suitable for importing into WinRDBI.
Header is changed to lowercase identifiers suffixed by the type of the field (/char or /numeric).
All data fields of type char are single-quoted. 
Assumptions: original csv data is not quoted and is separated by a ,
If the original data contains single quotes, then the resulting file will not import due to quoting issues.
This code checks whether there are any missing fields in the csv and generates an appropriate error message.
'''
import pandas as pd
import csv as csv
import numbers
FILENAME = 'TOBESPECIFIED'
flights = pd.read_csv(FILENAME+'.csv',sep=',')
if flights.isnull().values.any():
    print("ERROR: Missing fields in csv")
else: 
    # Change header names to lowercase and add type; Write separately from data so that header is not quoted for WinRDBI
    flights = flights.rename(columns=lambda h: h.lower() + ('/numeric' if isinstance(flights[h][0], numbers.Number) else '/char'))
    with open(FILENAME+'_quoted.csv', mode='w') as f:
        f.write(','.join(list(flights.columns)) + '\n')
    flights.to_csv(FILENAME+'_quoted.csv', mode='a', sep=',', quotechar="'", quoting=csv.QUOTE_NONNUMERIC, index=None, header=False)

