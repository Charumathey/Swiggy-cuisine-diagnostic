import sqlite3, random
from datetime import date, timedelta

random.seed(42)

conn = sqlite3.connect("swiggy_capstone.db")
cur = conn.cursor()

cur.executescript("""
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cuisine_targets;

CREATE TABLE restaurants (
    restaurant_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    cuisine TEXT NOT NULL,
    city TEXT NOT NULL
);
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    signup_date TEXT NOT NULL,
    city TEXT NOT NULL
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    amount_inr INTEGER NOT NULL,
    rating INTEGER,
    status TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);
CREATE TABLE cuisine_targets (
    cuisine TEXT PRIMARY KEY,
    target_revenue_inr INTEGER NOT NULL
);
""")

cities = ["Mumbai", "Bengaluru", "Delhi", "Kolkata"]
cuisines = ["North Indian", "South Indian", "Chinese", "Italian", "Fast Food", "Desserts"]

restaurant_names = [
    "Spice Junction","Curry Leaf House","Wok This Way","Roma Pizzeria","Burger Barn","Sweet Tooth Bakery",
    "Tandoor Nights","Dosa Point","Dragon Bowl","Napoli Slice","Grill & Chill","Choco Delight",
    "Punjab Rasoi","Idli Express","Sugar Rush"
]
restaurants = []
for i, rname in enumerate(restaurant_names, start=1):
    cuisine = cuisines[(i - 1) % len(cuisines)]
    city = cities[(i - 1) % len(cities)]
    restaurants.append((i, rname, cuisine, city))
cur.executemany("INSERT INTO restaurants VALUES (?,?,?,?)", restaurants)

first_names = ["Aarav","Vivaan","Aditya","Vihaan","Arjun","Sai","Reyansh","Ayaan","Krishna","Ishaan",
               "Ananya","Diya","Saanvi","Aadhya","Kiara","Myra","Anika","Navya","Riya","Siya",
               "Rohan","Kabir","Dev","Yash","Aryan","Zara","Meera","Tara","Nisha","Priya",
               "Aman","Rahul","Karan","Varun","Nikhil","Pooja","Neha","Simran","Divya","Isha",
               "Rohit","Sanjay","Vikram","Manish","Deepak","Kavya","Shreya","Anjali","Pallavi","Sneha"]
customers = []
start_signup = date(2025, 1, 1)
for i, fname in enumerate(first_names, start=1):
    city = cities[i % len(cities)]
    signup = start_signup + timedelta(days=random.randint(0, 400))
    customers.append((i, fname, signup.isoformat(), city))
cur.executemany("INSERT INTO customers VALUES (?,?,?,?)", customers)

popularity_weights = [10, 3, 8, 2, 6, 1, 9, 2, 7, 1, 5, 2, 8, 3, 1]
order_date_start = date(2026, 1, 1)
order_date_end = date(2026, 6, 30)
total_days = (order_date_end - order_date_start).days

TOTAL_ORDERS = 420
restaurant_ids_weighted = []
for rid, w in zip(range(1, 16), popularity_weights):
    restaurant_ids_weighted.extend([rid] * w)

orders = []
order_id = 1
for _ in range(TOTAL_ORDERS):
    cust_id = random.randint(1, 50)
    rest_id = random.choice(restaurant_ids_weighted)
    day_offset = random.randint(0, total_days)
    o_date = order_date_start + timedelta(days=day_offset)
    amount = random.randint(150, 2500)
    roll = random.random()
    if roll < 0.85:
        status, rating = "Delivered", random.randint(1, 5)
    elif roll < 0.95:
        status, rating = "Cancelled", None
    else:
        status, rating = "Pending", None
    orders.append((order_id, cust_id, rest_id, o_date.isoformat(), amount, rating, status))
    order_id += 1
cur.executemany("INSERT INTO orders VALUES (?,?,?,?,?,?,?)", orders)

cuisine_targets = [
    ("North Indian", 180000), ("Chinese", 140000), ("South Indian", 50000),
    ("Fast Food", 60000), ("Desserts", 25000), ("Italian", 10000),
]
cur.executemany("INSERT INTO cuisine_targets VALUES (?,?)", cuisine_targets)

conn.commit()
conn.close()
print("swiggy_capstone.db created.")