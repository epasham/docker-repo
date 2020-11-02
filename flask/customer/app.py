import flask
import psycopg2
import os
from flask import request, jsonify
from psycopg2 import pool
from gevent.pywsgi import WSGIServer
from contextlib import contextmanager

DB_HOST = os.getenv("DB_HOST")
DB_PORT = int(os.getenv("DB_PORT", 5432))
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_CP_MIN_CONN = int(os.getenv("DB_CP_MIN_CONN", 1))
DB_CP_MAX_CONN = int(os.getenv("DB_CP_MAX_CONN", 20))

conPool = pool.SimpleConnectionPool(DB_CP_MIN_CONN, DB_CP_MAX_CONN, user=DB_USER,
                            password=DB_PASSWORD,
                            host=DB_HOST,
                            port=DB_PORT,
                            dbname=DB_NAME)

app = flask.Flask(__name__)

# Get Cursor
@contextmanager
def get_cursor():
    con = conPool.getconn()
    cur = con.cursor()
    try:
        yield con, cur
    finally:
        cur.close()
        conPool.putconn(con)


@app.route('/', methods=['GET'])
def hello():
    return "Hello, World!"

@app.route('/customer', methods=['POST'])
def addCustomer():
    customer = request.get_json(force=True)
    insert_sql = """ INSERT INTO Customer (ID, NAME, ADDRESS) VALUES (%s,%s,%s)  RETURNING id"""
    records = (customer['id'],customer['name'], customer['address'])
    with get_cursor() as (connection, cursor):
        try:
            cursor.execute(insert_sql, records)
            my_id = cursor.fetchone()
            rowcount = cursor.rowcount
            if rowcount == 1:
                connection.commit()
            else:
                connection.rollback()
        except psycopg2.Error as error:
            print('Database error:', error)
        except Exception as ex:
            print('General error:', ex)
            
    return jsonify(customer)
        

@app.route('/customer/<id>', methods=['GET'])
def getCustomer(id):
    query = "select * from customer where id=%s"
    with get_cursor() as (connection, cursor):
        try:           
            cursor.execute(query, (id,))
            row = cursor.fetchone()
            if row is not None:
                customer = {
                    "id": row[0],
                     "name": row[1],
                     "address": row[2]
                }
                return jsonify(customer)
        except psycopg2.Error as error:
            print('Database error:', error)
        except Exception as ex:
            print('General error:', ex)
        

    return jsonify({})

@app.route('/customer/<id>', methods=['DELETE'])
def deleteCustomer(id):
    query = "delete from customer where id=%s RETURNING (select_list | *)"
    with get_cursor() as (connection, cursor):
        try:
            cursor.execute(query, (id,))
        except psycopg2.Error as error:
            print('Database error:', error)
        except Exception as ex:
            print('General error:', ex)

    return jsonify({})
        

@app.route('/customer', methods=['PUT'])
def updateCustomer():
    query = "update customer set name=%s, address=%s where id=%s RETURNING *"
    customer = request.get_json(force=True)
    records = (customer['name'], customer['address'],customer['id'])
    with get_cursor() as (connection, cursor):
        try:
            cursor.execute(query, records)
            my_id = cursor.fetchone()
            rowcount = cursor.rowcount
            if rowcount == 1:
                connection.commit()
            else:
                connection.rollback()
        except psycopg2.Error as error:
            print('Database error:', error)
        except Exception as ex:
            print('General error:', ex)

    return jsonify(customer)


if __name__ == '__main__':
    # Debug/Development
    # app.run(host='0.0.0.0', port=5000, debug=True)

    # Production
    http_server = WSGIServer(('', 5000), app)
    http_server.serve_forever()
