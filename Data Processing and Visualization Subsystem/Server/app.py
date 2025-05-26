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
client_mongo = MongoClient("database_url")
db = client_mongo['test']
collection = db['weight_readings']

# Load pretrained model and scaler
scaler = joblib.load("scaler.pkl")
model = joblib.load("isolation_forest_model.pkl")

# Twilio setup
account_sid = "account_sid"
auth_token = "auth_token"
twilio_client = Client(account_sid, auth_token)
twilio_from = "twilio_number"
twilio_to = "receiver_number"

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
