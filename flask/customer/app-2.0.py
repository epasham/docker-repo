import flask
import psycopg2
import os
from flask import request, jsonify
from psycopg2 import pool

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

@app.route('/customer', methods=['POST'])
def addCustomer():
    customer = request.get_json(force=True)
    connection = conPool.getconn()
    if (connection):
        cursor = connection.cursor()
        insert_sql = """ INSERT INTO Customer (ID, NAME, ADDRESS) VALUES (%s,%s,%s)"""
        records = (customer['id'],customer['name'], customer['address'])
        cursor.execute(insert_sql, records)
        connection.commit()
        cursor.close()
        connection.close()
        return ''

@app.route('/customer/<id>', methods=['GET'])
def getCustomer(id):
    connection = conPool.getconn()
    if (connection):
        cursor = connection.cursor()
        query = "select * from customer where id=%s"
        cursor.execute(query, (id,))
        row = cursor.fetchone()
        cursor.close()
        connection.close()
        if row is not None:
            customer = {
                "id": row[0],
                "name": row[1],
                "address": row[2]
            }
            return jsonify(customer)
        return jsonify({})

@app.route('/customer/<id>', methods=['DELETE'])
def deleteCustomer(id):
    connection = conPool.getconn()
    if (connection):
        cursor = connection.cursor()
        query = "delete from customer where id=%s"
        cursor.execute(query, (id,))
        connection.commit()
        cursor.close()
        connection.close()
        return ''

@app.route('/customer', methods=['PUT'])
def updateCustomer():
    connection = conPool.getconn()
    if (connection):
        customer = request.get_json(force=True)
        cursor = connection.cursor()
        query = "update customer set name=%s, address=%s where id=%s"
        records = (customer['name'], customer['address'],customer['id'])
        cursor.execute(query, records)
        connection.commit()
        cursor.close()
        connection.close()
        return ''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

