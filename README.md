# 🌾 AgriConnect – Smart Farming Machinery Booking Platform

> “Connecting Farmers, Machines & Intelligence – One Platform”

---

## 📌 Table of Contents

- Overview
- Problem Statement
- Solution
- Features
- System Architecture
- Tech Stack
- App Flow
- Voice AI System
- Multilingual System
- Payment System
- Folder Structure
- Installation Guide
- API Structure
- Database Design
- Future Enhancements
- Screenshots
- Contributors
- License

---

## 🌍 Overview

AgriConnect is a **full-stack smart agriculture platform** that enables:

- Farmers to book machinery
- Owners to rent out equipment
- AI-powered voice interaction
- Offline multilingual support
- Secure payment system

This project is designed to **digitize rural farming operations** and reduce dependency on middlemen.

---

## ❗ Problem Statement

Farmers face multiple challenges:

- 🚜 No easy access to machinery
- 💸 High dependency on middlemen
- 📞 Language barriers
- ⏱️ Time-consuming booking process

---

## 💡 Solution

AgriConnect solves this with:

- 📱 Mobile-based booking system
- 🎤 Voice-enabled booking (AI powered)
- 🌐 Multi-language interface
- 💳 Secure digital payments
- 🔁 Real-time availability tracking

---

## ✨ Features

### 👨‍🌾 Farmer Features

- Register & login
- Search machinery
- Voice booking system
- Multi-language UI
- Track bookings
- Online/Offline payments

---

### 🧑‍🔧 Owner Features

- Add machinery
- Manage availability
- Accept/reject bookings
- Track earnings

---

### 🤖 Smart Features

- Voice AI booking
- Offline language translation
- Smart recommendations

---

## 🏗️ System Architecture

![Architecture](assets/architecture.png)

```bash
User (Farmer/Owner)
        ↓
Flutter App (UI Layer)
        ↓
Voice Module + Language Engine
        ↓
Backend (Supabase)
        ↓
Database (PostgreSQL)
```
---

## 📱 App Flow

![Flow](assets/app_flow.png)

1. User selects role (Farmer / Owner)
2. Login / Signup
3. Farmer → Search Machinery
4. Voice/Text Booking
5. Owner → Accept Request
6. Payment → Confirmation

---

## 🎤 Voice AI System

![Voice Flow](assets/voice_flow.png)

### Flow:

1. User speaks
2. Speech → Text (Whisper)
3. NLP Intent Detection
4. Booking Action Trigger

### Tech:

- Google Whisper (offline possible)
- Custom NLP model
- Rule-based fallback

---

## 🌐 Multilingual System

![Language Flow](assets/language_flow.png)

Supports:

- English
- Tamil
- Hindi

### How it works:

- JSON-based offline translation
- Dynamic UI rendering

```json
{
  "book_now": {
    "en": "Book Now",
    "ta": "இப்போது பதிவு செய்",
    "hi": "अभी बुक करें"
  }
}
```
## 💳 Payment System

### Modes:

- Pre-payment

- Post-payment


### Flow:

1. Booking created
2. Payment intent generated
3. User pays
4. Confirmation stored

### 🛠️ Tech Stack

- Frontend
- Flutter
- Backend
- Supabase

### Database

- PostgreSQL

### AI

- Whisper AI (voice)
- NLP model (intent detection)

## 📂 Folder Structure

```bash
agriconnect/
│
├── lib/
│   ├── screens/
│   ├── models/
│   ├── services/
│   ├── widgets/
│
├── backend/
│   ├── routes/
│   ├── controllers/
│   ├── models/
│
├── assets/
│   ├── images/
│   ├── translations/
│
├── README.md
```

## ⚙️ Installation Guide
# 1️⃣ Clone repo
```bash
git clone https://github.com/dhanusiyasri/AgriConnect
cd AgriConnect
```

# 2️⃣ Install dependencies
```bash
flutter pub get
```

# 3️⃣ Run project
```bash
flutter run
```

## 🔌 API Structure

| Endpoint    | Method | Description        |
|------------|--------|--------------------|
| /login     | POST   | User login         |
| /machines  | GET    | Fetch machines     |
| /book      | POST   | Create booking     |
| /payment   | POST   | Payment processing |
---

## 🗄️ Database Design

Collections:

- Users

- Machines

- Bookings

- Payments

---

## 🚀 Future Enhancements

- AI crop suggestions

- IoT integration

- Real-time GPS tracking

- Group booking

- Drone services

---
  
## 🧠 Learnings

- Full-stack architecture

- AI integration in mobile apps

- Payment gateway integration

- Offline-first design

---

👨‍💻 Contributors
- Dhanusiya Sri M
- Dhiyaneshwar C S
- Sarabheswaran E S
- Dhivyadharshini M
- Sarathi Selvam D
- Saisha priyadarshini S
---
