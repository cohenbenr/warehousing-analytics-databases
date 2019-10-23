#import numpy as np
import pandas as pd
import os
from sqlalchemy import create_engine

os.getcwd()
os.listdir()

engine = create_engine('postgresql://postgres@localhost:5432/salesdata')

customers = pd.read_sql_query('SELECT * FROM customers;', con=engine)
employees = pd.read_sql_query('SELECT * FROM employees;', con=engine)
orders = pd.read_sql_query('SELECT * FROM orders;', con=engine)
order_items = pd.read_sql_query('SELECT * FROM order_items;', con=engine)
products = pd.read_sql_query('SELECT * FROM products;', con=engine)

order_items.columns
orders.columns
customers.columns
products.columns
employees.columns

#measures table- order_items
oi = order_items[['order_item_id', 'quantity_ordered', 'price_each', 'order_number', 'product_code', 'required_date',
                  'shipped_date','status']]
oi = pd.merge(oi, orders[['order_number', 'sales_rep_employee_number','customer_number']],
              how='left', left_on='order_number', right_on='order_number')

oi_dates = oi[['order_item_id', 'required_date', 'shipped_date']]

oi_status = oi[['order_item_id', 'status']]

oi.drop(['required_date','shipped_date','status'],axis=1,inplace=True)

o = orders.drop(['sales_rep_employee_number','customer_number'],axis=1)

engine = create_engine('postgresql://postgres@localhost:5432/salesdata_analytics')
oi.to_sql('order_items', engine, if_exists='append', index=False)
oi_dates.to_sql('order_item_dates', engine, if_exists='append', index=False)
oi_status.to_sql('order_item_status', engine, if_exists='append', index=False)
o.to_sql('orders', engine, if_exists='append', index=False)
products.to_sql('products', engine, if_exists='append', index=False)
customers.to_sql('customers', engine, if_exists='append', index=False)
employees.to_sql('employees',engine,if_exists='append',index=False)









