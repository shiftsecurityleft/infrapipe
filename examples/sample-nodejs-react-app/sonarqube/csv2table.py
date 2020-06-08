import pandas
from tabulate import tabulate

data = pandas.read_csv('./sonarscan-result.csv', index_col=0, sep=',')
print(tabulate(data, headers=data.columns, tablefmt="grid"))

