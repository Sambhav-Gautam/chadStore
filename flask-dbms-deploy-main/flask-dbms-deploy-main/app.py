from flask import Flask, render_template, request, redirect, session, jsonify, url_for
from flask_mysqldb import MySQL
import mysql.connector
import os

app = Flask(__name__, static_url_path='/static')
app.secret_key = os.urandom(24)

db = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="EnterYourPassword",
    database="dbms"
)
# Function to execute SQL queries
def execute_query(query, data=None):
    cursor = db.cursor(buffered=True)
    cursor.execute(query, data)
    db.commit()
    cursor.close()
# Function to create the login_attempts table
def create_login_attempts_table():
    query = """
        CREATE TABLE IF NOT EXISTS login_attempts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            success INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """
    execute_query(query)

# Call this function before creating the trigger
create_login_attempts_table()



def create_login_failed_trigger():
    drop_trigger_query = "DROP TRIGGER IF EXISTS login_failed_trigger"
    execute_query(drop_trigger_query)

    # Proceed with creating the trigger as before
    trigger_query = """
    CREATE TRIGGER login_failed_trigger
    AFTER INSERT ON login_attempts
    FOR EACH ROW
    BEGIN
        DECLARE attempts INT;
        DECLARE is_blocked INT;
        
        -- Count the number of failed attempts for this user
        SELECT COUNT(*) INTO attempts FROM login_attempts WHERE user_id = NEW.user_id AND success = 0;
        
        -- Check if the number of attempts exceeds the threshold
        IF attempts >= 3 THEN
            -- Set the user's status to blocked
            UPDATE CUSTOMER SET CUSTOMER_STATUS = 'Blocked' WHERE CUSTOMER_ID = NEW.user_id;
        END IF;
    END;
"""

    execute_query(trigger_query)



# Function to record a login attempt
def record_login_attempt(user_id, success):
    query = "INSERT INTO login_attempts (user_id, success) VALUES (%s, %s)"
    execute_query(query, (user_id, success))

# Route for simulating a login attempt
@app.route('/login_attempt', methods=['POST'])
def login_attempt():
    # Simulated login attempt
    user_id = request.form['user_id']
    success = 1  # Assume success for demonstration
    record_login_attempt(user_id, success)
    return "Login attempt recorded successfully!"

@app.route('/offer')
def offer():
    return render_template('offer.html')

@app.route('/home')
def hello_world():
    if 'CUSTOMER_ID' in session:
        cursor = db.cursor(buffered=True)
        cursor.execute("SELECT * FROM PRODUCTS")
        products = cursor.fetchall()
        cursor.close()  # Close the cursor after fetching all results
        
        cursor = db.cursor(buffered=True)  # Re-open cursor for a new query
        query1 = "SELECT * FROM product_category"
        cursor.execute(query1)
        products_categorys = cursor.fetchall()
        cursor.close()
         # Filter products to include only those from the 'Grocery' category
        
        return render_template('index.html', products=products, products_categorys=products_categorys)
    return redirect('/')

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'signin':
            username = request.form['username']
            password = request.form['password']
            cursor = db.cursor(buffered=True)
            query = "SELECT CUSTOMER_ID, CUSTOMER_PASSWORD, CUSTOMER_STATUS FROM CUSTOMER WHERE CUSTOMER_NAME = %s"
            cursor.execute(query, (username,))
            result = cursor.fetchone()
            cursor.close()  # Close the cursor after fetching the result
            if result is None:
                return "Invalid username"
            elif result[1] == password:
                if result[2] == 'Blocked':
                    return "Your account is blocked. Please contact support."
                else:
                    session['CUSTOMER_ID'] = result[0]
                    return redirect('/home')
            else:
                record_login_attempt(result[0], 0)  # Pass CUSTOMER_ID instead of username
                return redirect('/')
        elif action == 'signup':
            username = request.form['username']
            email = request.form['email']
            password = request.form['password']
            cur = db.cursor(buffered=True)
            cur.execute("INSERT INTO CUSTOMER (CUSTOMER_NAME, CUSTOMER_PASSWORD, CUSTOMER_EMAIL) VALUES (%s, %s, %s)", (username, password, email))
            db.commit()
            cur.close()  # Close the cursor after executing the query
            return redirect('/home')
        else:
            return "Invalid action"
    return render_template('login.html')



@app.route('/logout')
def logout():
	if 'CUSTOMER_ID' in session:
		session.pop('CUSTOMER_ID')
	
	return redirect('/')



@app.route('/search', methods=['POST', 'GET'])
def search():
	word = request.args.get('query').lower()

	if len(word) != 0 :
		cursor = db.cursor(buffered=True)
		query = "SELECT * FROM PRODUCTS WHERE LOWER(PRODUCT_NAME) LIKE %s"
		cursor.execute(query, ('%' + word[0] + '%' ,))
		# query = "SELECT * FROM PRODUCTS"
		# cursor.execute(query)
		result = cursor.fetchall()
		query1 = "SELECT * FROM product_category"
		cursor.execute(query1)
		products_categorys = cursor.fetchall()
		cursor.close()
		return render_template('search.html',word=word, result=result, products_categorys=products_categorys)
	
	cursor = db.cursor(buffered=True)
	query = "SELECT * FROM PRODUCTS"
	cursor.execute(query)
	result = cursor.fetchall()
	query1 = "SELECT * FROM product_category"
	cursor.execute(query1)
	products_categorys = cursor.fetchall()
	cursor.close()
	return render_template('search.html',word=word, result=result, products_categorys=products_categorys)


@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/cart')
def cart():
	if 'CUSTOMER_ID' in session:
		# Retrieve CUSTOMER_ID from session
		customer_id = session['CUSTOMER_ID']
		
		cursor = db.cursor(buffered=True)
		cursor.execute("""
			SELECT c.QUANTITY, p.product_name, p.price, p.image_data, p.id
			FROM CART c
			JOIN products p ON c.PRODUCT_ID = p.id
			WHERE c.CART_ID = %s
		""", (customer_id,))
            
		cart_items = cursor.fetchall()
		total_price = 0
		for i in cart_items:
			total_price = total_price + (i[0] * i[2])
		return render_template('cart.html', cart_items=cart_items, total_price=total_price)
	else:
		return redirect('/')

@app.route('/place_order', methods=['GET'])
def place_order():
    if 'CUSTOMER_ID' in session:
        # Clear the cart for the current user
        customer_id = session['CUSTOMER_ID']
        cursor = db.cursor(buffered=True)
        cursor.execute("DELETE FROM CART WHERE CART_ID = %s", (customer_id,))
        db.commit()
        cursor.close()
        
        # Render the success page
        return render_template('order_success.html')
    else:
        return redirect('/')
    
	
@app.route('/remove_from_cart', methods=['GET'])
def remove_from_cart():
    if 'CUSTOMER_ID' in session:
        customer_id = session['CUSTOMER_ID']
        product_id = request.args.get('product_id')

        cursor = db.cursor(buffered=True)
        cursor.execute("DELETE FROM CART WHERE CART_ID = %s AND PRODUCT_ID = %s", (customer_id, product_id))
        db.commit()
        cursor.close()

        return redirect('/cart')
    else:
        return redirect('/')




@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    if 'CUSTOMER_ID' in session:
        customer_id = session['CUSTOMER_ID']
    
    data = request.json
    product_id = data.get('productId')
    
    cursor = db.cursor(buffered=True)
    
    cursor.execute("SELECT * FROM CART WHERE CART_ID = %s AND PRODUCT_ID = %s", (customer_id, product_id))
    existing_product = cursor.fetchone()

    if existing_product:
        new_quantity = existing_product[1] + 1  
        cursor.execute("UPDATE CART SET QUANTITY = %s WHERE CART_ID = %s AND PRODUCT_ID = %s", (new_quantity, customer_id, product_id))
    else:
        cursor.execute("INSERT INTO CART (CART_ID, PRODUCT_ID, QUANTITY) VALUES (%s, %s, %s)", (customer_id, product_id, 1))

    db.commit()
    return jsonify({'message': 'Product added to cart successfully', 'cart': [1, 2, 3]})

@app.route('/add_address', methods=['POST', 'GET'])
def add_address():
      return render_template('add.html')


if __name__ == "__main__":
    # Trigger 1: Login Failure Trigger
    create_login_failed_trigger()
    app.run(debug=True)