# Flutter + Node.js + MongoDB App

This is a complete full-stack boilerplate app.

## Project Structure
- `backend/`: Node.js + Express API app.
- `frontend/`: Flutter frontend app.

## Prerequisites
- Node.js installed
- Flutter SDK installed
- MongoDB installed and running locally on `mongodb://localhost:27017`

## Running the Backend
1. Open a terminal and navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Start the server:
   ```bash
   node index.js
   ```
The server will run on port 3000.

## Running the Frontend
1. Open another terminal and navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Run the Flutter app (make sure you have an emulator or device connected):
   ```bash
   flutter run
   ```

## Note on API Connection
The Flutter app is configured to connect to `http://10.0.2.2:3000/api/todos` for Android emulators (which is how Android emulators access `localhost` on the host machine) and `http://localhost:3000/api/todos` for others.
