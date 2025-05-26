from pymongo import MongoClient
import certifi

client = MongoClient(
    "mongodb+srv://zolilemikezoko:zolilemikezoko@waddleway.cafrdzu.mongodb.net/?retryWrites=true&w=majority&appName=WaddleWay",
    tls=True,
    tlsCAFile=certifi.where()
)

try:
    print(client.server_info())
except Exception as e:
    print("Connection failed:", e)
