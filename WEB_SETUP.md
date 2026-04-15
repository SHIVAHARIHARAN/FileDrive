# Web File Upload Setup Guide

## What Changed
✅ Updated API service to support **web file uploads** in Chrome  
✅ File picker now works for both mobile (file paths) and web (file bytes)  
✅ Backend CORS is already enabled  
✅ Web build is ready to run

## Backend Setup

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Create .env File
Create a `.env` file in the `backend` folder:
```
MONGODB_URI=your_mongodb_connection_string
PORT=5000
```

### 3. Create Uploads Directory
```bash
# In backend folder
mkdir uploads
```

### 4. Start Backend Server
```bash
# In backend folder
npm start
# Or for development with hot reload:
npm run dev
```

The backend will run on `http://localhost:5000`

## Frontend Setup

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Configure API URL
The API is already configured to use `http://localhost:5000/api` for web.

If you need to use a different IP/port, edit:
```
frontend/lib/services/api_service.dart
// Line: static const String baseUrl = 'http://localhost:5000/api';
```

### 3. Run on Web (Chrome)
```bash
cd frontend
flutter run -d chrome
```

Or build for production:
```bash
flutter build web
```

### 4. Run on Mobile/Android (if needed)
Update the `baseUrl` in `api_service.dart` to your machine's IP:
```dart
static const String baseUrl = 'http://10.0.0.100:5000/api'; // Replace with your IP
```

Then run:
```bash
flutter run
```

## Features
- ✅ Upload files from web browser (Chrome)
- ✅ Create folders
- ✅ View files and folders
- ✅ User authentication
- ✅ File management

## Troubleshooting

### CORS Errors
- Backend has CORS enabled by default
- Make sure backend is running before accessing from web

### Upload Directory Issues
- Ensure `backend/uploads` directory exists
- The server will use this to store uploaded files

### API Connection Issues
- Verify `http://localhost:5000` is accessible
- Check that backend port matches in `api_service.dart`
- Browser console should show network requests in DevTools (F12)

## File Upload Flow
1. User clicks "Upload File" button
2. File picker opens (works in Chrome)
3. User selects a file
4. File is sent as MultipratRequest to backend
5. Backend saves file with unique name
6. File metadata is stored in MongoDB
7. File appears in folder list

## API Endpoints
- `POST /api/files` - Upload file
- `GET /api/files?folderId=X` - Get files in folder
- `DELETE /api/files/:id` - Delete file
- `POST /api/folders` - Create folder
- `GET /api/folders` - Get folders
- `POST /api/auth/login` - Login
- `POST /api/auth/signup` - Signup
