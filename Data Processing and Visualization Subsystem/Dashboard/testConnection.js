const db = require('./db'); // Import your connection module

// Test the connection
db.connectToDb((err) => {
  if (err) {
    console.error('Failed to connect:', err);
    process.exit(1); // Exit with error
  } else {
    console.log('Successfully connected to MongoDB!');
    
    // Optional: Test a simple database operation
    const database = db.getDb();
    if (database) {
      database.collection('test').findOne({}, (err, result) => {
        if (err) {
          console.error('Test query failed:', err);
        } else {
          console.log('Test query result:', result);
        }
        process.exit(0); // Exit successfully
      });
    } else {
      console.error('Database connection not established!');
      process.exit(1);
    }
  }
});