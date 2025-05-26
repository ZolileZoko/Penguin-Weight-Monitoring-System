from flask import Flask, request, jsonify, Response
from flask_pymongo import PyMongo
from datetime import datetime
import csv
from io import StringIO

app = Flask(__name__)

# Configure your MongoDB URI here
app.config["MONGO_URI"] = "mongodb+srv://zolilemikezoko:zolilemikezoko@waddleway.cafrdzu.mongodb.net/?retryWrites=true&w=majority&appName=WaddleWay"
mongo = PyMongo(app)

@app.route('/api/weight_readings', methods=['POST'])
def add_weight_reading():
    data = request.get_json()

    # Basic validation
    required_fields = ['rfid', 'weight', 'timestamp', 'device_id']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400

    # Convert timestamp string to datetime
    try:
        data['timestamp'] = datetime.fromisoformat(data['timestamp'].replace("Z", "+00:00"))
    except Exception:
        return jsonify({"error": "Invalid timestamp format"}), 400

    # Insert into MongoDB collection "weight_readings"
    result = mongo.db.weight_readings.insert_one(data)

    return jsonify({"message": "Weight reading added", "id": str(result.inserted_id)}), 201

@app.route('/api/weight_readings', methods=['GET'])
def get_weight_readings():
    start_date_str = request.args.get('start')
    end_date_str = request.args.get('end')

    query = {}
    if start_date_str and end_date_str:
        try:
            start_date = datetime.fromisoformat(start_date_str)
            end_date = datetime.fromisoformat(end_date_str)
            query = {"timestamp": {"$gte": start_date, "$lte": end_date}}
        except Exception:
            return jsonify({"error": "Invalid date format. Use ISO 8601 format (e.g. 2025-05-22T00:00:00)"}), 400

    cursor = mongo.db.weight_readings.find(query).sort("timestamp", 1)
    data = list(cursor)

    if not data:
        return jsonify({"error": "No data found for the given range."}), 404

    si = StringIO()
    csv_writer = csv.writer(si)

    # Write header row
    header = data[0].keys()
    csv_writer.writerow(header)

    # Write data rows
    for doc in data:
        csv_writer.writerow([doc.get(field, "") for field in header])

    output = si.getvalue()
    si.close()

    return Response(
        output,
        mimetype="text/csv",
        headers={"Content-Disposition": "attachment;filename=weight_readings.csv"}
    )

if __name__ == '__main__':
    app.run(debug=True)
