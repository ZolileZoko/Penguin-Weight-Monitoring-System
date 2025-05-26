from flask import Flask, request, jsonify
from pymongo import MongoClient
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from twilio.rest import Client
from datetime import datetime
import numpy as np
import joblib

app = Flask(__name__)

# MongoDB setup
client_mongo = MongoClient("mongodb+srv://zolilemikezoko:zolilemikezoko@waddleway.cafrdzu.mongodb.net/?retryWrites=true&w=majority&appName=WaddleWay")
db = client_mongo['test']
collection = db['weight_readings']

# Load pretrained model and scaler
scaler = joblib.load("scaler.pkl")
model = joblib.load("isolation_forest_model.pkl")

# Twilio setup
account_sid = "AC2f2f042f3b77f314da74810869f6fe37"
auth_token = "1c1a5da27f085e6f7b40546454c5f3dc"
twilio_client = Client(account_sid, auth_token)
twilio_from = "+16067052527"
twilio_to = "+27730969889"

@app.route('/api/weight_readings', methods=['POST'])
def receive_data():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON"}), 400

    data['received_at'] = datetime.utcnow().isoformat()

    try:
        weight = float(data.get('weight', 0))
    except (TypeError, ValueError):
        return jsonify({"error": "Invalid weight value"}), 400

    # Scale the input before prediction
    weight_scaled = scaler.transform([[weight]])
    score = model.predict(weight_scaled)

    if score[0] == -1:
        # Anomaly detected
        message = f"?? Alert! Abnormal penguin weight: {weight}g detected."
        twilio_client.messages.create(
            body=message,
            from_=twilio_from,
            to=twilio_to
        )

    collection.insert_one(data)
    return jsonify({"message": "Data stored", "anomaly": score[0] == -1}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
