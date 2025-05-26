const { MongoClient } = require('mongodb');

// Connection URI - Verify your database name is correct!
const uri = 'mongodb+srv://zolilemikezoko:Qwerty2002@waddleway.cafrdzu.mongodb.net/penguin_tracking?retryWrites=true&w=majority&appName=WaddleWay';

async function runTests() {
  const client = new MongoClient(uri);
  
  try {
    // 1. Connect and verify database
    console.log("Connecting to MongoDB...");
    await client.connect();
    const db = client.db('test');
    console.log("Connected to database:", db.databaseName);

    // Verify collections exist (create if needed)
    const collections = await db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    console.log("Existing collections:", collectionNames);

    if (!collectionNames.includes('penguins')) {
      await db.createCollection('penguins');
      console.log("Created 'penguins' collection");
    }

    if (!collectionNames.includes('weight_readings')) {
      await db.createCollection('weight_readings');
      console.log("Created 'weight_readings' collection");
    }

    // 2. Sample data with validation
    const samplePenguin = {
      rfid: "PENGUIN_" + Math.floor(Math.random() * 1000),
      colony: "Boulders Beach",
      species: "African Penguin",
      sex: "unknown",
      age: 2,
      tags: ["test_data"],
      last_weight: parseFloat((Math.random() * 5 + 2).toFixed(1)), // Ensure number type
      last_measured: new Date()
    };

    // 3. Explicit collection references
    const penguinsCollection = db.collection('penguins');
    const weightsCollection = db.collection('weight_readings');

    // 4. Insert with confirmation
    console.log("\nInserting into PENGUINS collection...");
    const penguinResult = await penguinsCollection.insertOne(samplePenguin);
    console.log(`Inserted into penguins: ${penguinResult.insertedId}`);

    const sampleWeight = {
      rfid: samplePenguin.rfid,
      weight: parseFloat((Math.random() * 5 + 2).toFixed(1)), // Ensure number type
      timestamp: new Date(),
      device_id: "scale_test"
    };

    console.log("\nInserting into WEIGHT_READINGS collection...");
    const weightResult = await weightsCollection.insertOne(sampleWeight);
    console.log(`Inserted into weight_readings: ${weightResult.insertedId}`);

    // 5. Verify exact collections
    const penguinCount = await penguinsCollection.countDocuments();
    const weightCount = await weightsCollection.countDocuments();
    console.log(`\nCollection counts:\n- penguins: ${penguinCount}\n- weight_readings: ${weightCount}`);

  } catch (err) {
    console.error("Operation failed:", err);
  } finally {
    await client.close();
    console.log("Connection closed");
  }
}

runTests();