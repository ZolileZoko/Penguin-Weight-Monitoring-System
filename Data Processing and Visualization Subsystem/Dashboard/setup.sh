#!/bin/bash

echo "🔧 Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git

echo "📦 Setting up virtual environment..."
python3 -m venv env
source env/bin/activate

echo "📦 Installing Python packages..."
pip install flask pymongo scikit-learn twilio gunicorn

echo "📁 Creating Flask app directory..."
mkdir -p ~/penguin-monitor
cd ~/penguin-monitor

echo "📄 Writing Flask app..."
cat > app.py << 'EOF'
from flask import Flask, request, jsonify
from pymongo import MongoClient
from sklearn.ensemble import IsolationForest
from twilio.rest import Client
from datetime import datetime
import numpy as np

app = Flask(__name__)

client_mongo = MongoClient("mongodb://localhost:27017/")
db = client_mongo['sensor_database']
collection = db['sensor_data']

# Isolation Forest setup
model = IsolationForest(contamination=0.01)
# Dummy training data for weight, retrain this on real data ideally
X_train = np.random.normal(loc=3000, scale=500, size=(1000, 1))
model.fit(X_train)

# Twilio credentials (set your environment variables securely!)
account_sid = "YOUR_TWILIO_SID"
auth_token = "YOUR_TWILIO_AUTH_TOKEN"
twilio_client = Client(account_sid, auth_token)
twilio_from = "YOUR_TWILIO_PHONE"
twilio_to = "DESTINATION_PHONE"

@app.route('/api/sensor', methods=['POST'])
def receive_data():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON"}), 400

    data['received_at'] = datetime.utcnow().isoformat()

    # Extract 'weight' for anomaly detection
    weight = float(data.get('weight', 0))
    score = model.predict([[weight]])
    
    if score[0] == -1:
        # anomaly detected
        message = f"🐧 Alert! Abnormal penguin weight: {weight}g detected."
        twilio_client.messages.create(
            body=message,
            from_=twilio_from,
            to=twilio_to
        )

    collection.insert_one(data)
    return jsonify({"message": "Data stored", "anomaly": score[0] == -1}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

EOF

echo "✅ Flask app ready. To run:"
echo "cd ~/penguin-monitor && source ../env/bin/activate && python app.py"

