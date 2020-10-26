import flask
import psycopg2
import os
from flask import request, jsonify
from psycopg2 import pool

app = flask.Flask(__name__)

conPool = pool.SimpleConnectionPool(1,20,user = "postgres",
                            password = "postgres",
                            host = "postgresdb",
                            port = "5432",
                            database = "customerdb")


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
