from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
CORS(app)

DB = '/tem/database.db'

def get_db():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    conn.execute('''CREATE TABLE IF NOT EXISTS 
        products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT)''')
    conn.execute('''CREATE TABLE IF NOT EXISTS 
        cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity INTEGER)''')
    # Sample data
    if not conn.execute(
        'SELECT * FROM products').fetchone():
        products = [
            ('Laptop', 45000, 'Core i5 8GB RAM'),
            ('Phone', 15000, 'Android 5G 128GB'),
            ('Headphones', 2500, 'Wireless BT'),
            ('Keyboard', 1200, 'Mechanical RGB'),
            ('Mouse', 800, 'Wireless Gaming'),
            ('Monitor', 12000, '24 inch FHD')
        ]
        conn.executemany(
            'INSERT INTO products VALUES (?,?,?,?)',
            [(None,)+p for p in products])
    conn.commit()
    conn.close()

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'ecommerce-backend',
        'version': '1.0'
    })

@app.route('/products', methods=['GET'])
def get_products():
    conn = get_db()
    products = conn.execute(
        'SELECT * FROM products').fetchall()
    conn.close()
    return jsonify([dict(p) for p in products])

@app.route('/products', methods=['POST'])
def add_product():
    data = request.json
    conn = get_db()
    conn.execute(
        'INSERT INTO products VALUES (?,?,?,?)',
        (None, data['name'],
         data['price'], data['description']))
    conn.commit()
    conn.close()
    return jsonify({'message': 'Added'}), 201

@app.route('/cart', methods=['GET'])
def get_cart():
    conn = get_db()
    items = conn.execute('''
        SELECT p.name, p.price, c.quantity,
        (p.price * c.quantity) as total
        FROM cart c 
        JOIN products p ON c.product_id=p.id
    ''').fetchall()
    conn.close()
    return jsonify([dict(i) for i in items])

@app.route('/cart', methods=['POST'])
def add_cart():
    data = request.json
    conn = get_db()
    conn.execute(
        'INSERT INTO cart VALUES (?,?,?)',
        (None, data['product_id'],
         data['quantity']))
    conn.commit()
    conn.close()
    return jsonify({'message': 'Added'}), 201
with app.app_context():
    init_db()

if __name__ == '__main__':
    app.run(host='0.0.0.0',
            port=5000, debug=True)