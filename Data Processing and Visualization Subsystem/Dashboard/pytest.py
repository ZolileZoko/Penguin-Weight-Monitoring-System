from pymongo import MongoClient

uri = 'mongodb+srv://zolilemikezoko:Qwerty2002@waddleway.cafrdzu.mongodb.net/penguin_tracking?retryWrites=true&w=majority&appName=WaddleWay'

client = MongoClient(uri)

try:
    print(client.server_info())  # Will attempt to connect and print server info
except Exception as e:
    print("Connection error:", e)
