penguin-weight-monitoring/  
│
├── **firmware/**                 # ESP32 Code (Arduino)  
│   ├── **main/**  
│   │   ├── main.ino             # Main ESP32 firmware  
│   │   ├── hx711_handler.cpp    # Load cell (HX711) interface  
│   │   ├── rfid_handler.cpp     # RFID reader (MFRC522/PN532)  
│   │   ├── rtc_handler.cpp      # Real-time clock (DS3231)  
│   │   ├── kalman_filter.cpp    # Weight noise filtering  
│   │   └── wifi_mqtt.cpp        # Wireless data transmission  
│   │
│   └── **libraries/**            # Required Arduino libraries  
│
├── **backend/**                  # Cloud Server (Node.js)  
│   ├── **models/**  
│   │   ├── Penguin.js           # Mongoose schema  
│   │   ├── WeightReading.js     # Weight data schema  
│   │   └── Colony.js            # Colony location schema  
│   │
│   ├── **routes/**  
│   │   ├── api.js               # REST API endpoints  
│   │   └── mqtt_handler.js      # MQTT data ingestion  
│   │
│   ├── **services/**  
│   │   ├── db.js               # MongoDB connection  
│   │   └── kalman_filter.js    # Server-side data smoothing  
│   │
│   └── server.js               # Express server  
│
├── **frontend/**                # Dashboard (HTML/CSS/JS)  
│   ├── **public/**  
│   │   ├── index.html          # Dashboard UI (TailwindCSS)  
│   │   ├── dashboard.js        # Real-time updates  
│   │   ├── maps.js             # Colony geospatial visualization  
│   │   └── analytics.js        # Weight trend charts  
│   │
│   └── package.json            # Frontend dependencies  
│
├── **database/**                # MongoDB Setup  
│   ├── init_collections.js     # Schema validation setup  
│   └── sample_data.json        # Mock penguin/colony data  
│
├── **docs/**  
│   ├── ER_Diagram.md           # Mermaid.js schema  
│   ├── hardware_setup.md       # Wiring guide  
│   └── api_docs.md            # REST API reference  
│
└── README.md                   # Project overview  
