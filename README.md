# MamaSafe App

## Overview

MamaSafe is a maternal health monitoring application designed to support **Community Health Workers (CHWs)** in detecting pregnancy risks early and referring mothers to healthcare professionals for further medical care.

The system collects maternal health data, predicts pregnancy risk levels (Low, Medium, High), and enables referrals and appointment scheduling between CHWs and healthcare professionals.

The goal of the application is to improve early detection of pregnancy complications and strengthen coordination in maternal healthcare services.

---

# Demo Video

Watch the full system demonstration here:

https://www.youtube.com/watch?v=Yui0GwxqLeA

The video demonstrates:

* Pregnancy risk prediction
* Referral workflow
* CHW dashboard functionality
* Healthcare professional dashboard
* Admin dashboard
* Testing with different maternal health data values

---

# Project Structure

MamaSafe-App
│
├── backend/           # Backend API and prediction logic
├── mama_safe/         # Flutter mobile application
├── screenshots/       # Application screenshots
└── README.md

---

# System Requirements

To run the project you need:

* Flutter SDK
* Python 3.x
* Android Studio or Android Emulator
* Git

---

# Installation and Setup (Step by Step)

## 1. Clone the Repository

```bash
git clone https://github.com/nellyiya/MamaSafe-App.git
cd MamaSafe-App
```

---

# Backend Setup

### 1. Navigate to the backend folder

```bash
cd backend
```

### 2. Install required dependencies

```bash
pip install -r requirements.txt
```

### 3. Run the backend server

```bash
python app.py
```

The backend API will start running locally.

---

# Flutter Application Setup

### 1. Navigate to the Flutter project folder

```bash
cd mama_safe
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Run the Flutter application

```bash
flutter run
```

The application will start on an emulator or connected Android device.

---

# Core Features

The MamaSafe system provides the following functionalities:

* Maternal health data collection
* Pregnancy risk prediction
* Referral system for high-risk cases
* Appointment scheduling
* Role-based dashboards

User roles include:

* Community Health Worker (CHW)
* Healthcare Professional
* Administrator

---

# Application Screenshots

Create a folder called **screenshots** in the repository and add the following images.

Example structure:

screenshots/
login.png
chw_dashboard.png
healthcare_dashboard.png
admin_dashboard.png

---

## Login Screen

![Login Screen](screenshots/login.png)
<img width="485" height="1015" alt="image" src="https://github.com/user-attachments/assets/ca6d1b4d-8bb5-49e2-8bdc-17a12a9e45ba" />

---

## CHW Dashboard
![CHW Dashboard]
<img width="488" height="1018" alt="image" src="https://github.com/user-attachments/assets/243dcc82-b74a-420d-9306-238a54874756" />

<img width="495" height="1009" alt="image" src="https://github.com/user-attachments/assets/30af3604-4bdb-4f9b-ac4a-fe1968a657ba" />



<img width="453" height="1008" alt="image" src="https://github.com/user-attachments/assets/e74eb633-c608-4145-970d-1895ed5f61ec" />
<img width="500" height="1012" alt="image" src="https://github.com/user-attachments/assets/902432a8-0972-4167-b910-8dbfadbf4367" />

---

## Healthcare Professional Dashboard

![Healthcare Professional Dashboard](screenshots/healthcare_dashboard.png)
<img width="507" height="973" alt="image" src="https://github.com/user-attachments/assets/a7e97bcf-8cac-4f07-8d23-fd7f718997bf" />
<img width="483" height="1016" alt="image" src="https://github.com/user-attachments/assets/00840453-ea3b-420a-9600-9b3ddefc5427" />
<img width="492" height="1019" alt="image" src="https://github.com/user-attachments/assets/d560c894-dc27-4d30-b7a4-62fa95755048" />
<img width="511" height="1026" alt="image" src="https://github.com/user-attachments/assets/acee930d-1c37-4490-9ce1-b502bd327707" />

---

## Admin Dashboard

![Admin Dashboard](screenshots/admin_dashboard.png)
<img width="1916" height="897" alt="image" src="https://github.com/user-attachments/assets/220c3bab-c7da-4ce7-906b-b53aa76b87aa" />
<img width="1913" height="911" alt="image" src="https://github.com/user-attachments/assets/8731ae26-0859-4bca-86a1-00856ba73fbd" />

---

# Testing and Implementation

## Demonstration of Functionality Under Different Testing Strategies

The application was tested using several testing strategies to ensure system reliability:

**Functional Testing**
Each feature of the system was tested to ensure it performs the expected function. For example, maternal data entered by CHWs correctly generates pregnancy risk predictions.

**Integration Testing**
The communication between the Flutter frontend and backend API was tested to ensure proper data exchange.

**Validation Testing**
Input validation ensures incomplete or invalid maternal health data cannot be submitted.

---

## Demonstration of Functionality with Different Data Values

The system was tested with multiple maternal health data values to confirm prediction accuracy.

Examples include:

**Low Risk Case**
Normal maternal health indicators resulting in a Low Risk classification.

**Medium Risk Case**
Moderately elevated indicators resulting in a Medium Risk classification.

**High Risk Case**
High blood pressure, high blood sugar, or fever resulting in a High Risk classification and referral recommendation.

These tests demonstrate the system's ability to correctly categorize pregnancy risk levels.

---

## Performance on Different Hardware or Software

The application was tested on different environments including:

* Android Emulator
* Physical Android Device
* Flutter development environment

The system maintained stable performance across these environments.

---

# Analysis

Testing results show that the system successfully achieves the main objectives defined in the project proposal.

The application effectively collects maternal health data, predicts pregnancy risks, and enables referrals between CHWs and healthcare professionals.

However, improvements can be made by expanding the dataset used for training the prediction model to improve prediction accuracy.

---

# Discussion

The project milestones were critical in ensuring the development of a functional system.

Major milestones included:

* Developing the maternal data collection system
* Integrating the pregnancy risk prediction model
* Implementing referral and dashboard features

These milestones demonstrate the potential of digital health solutions in improving maternal healthcare services.

---

# Recommendations

The system can support maternal healthcare programs by assisting CHWs in identifying high-risk pregnancies earlier.

Healthcare organizations may consider integrating digital tools like MamaSafe to improve maternal health monitoring and referral systems.

---

# Future Work

Future improvements may include:

* Integration with hospital information systems
* Expanding datasets to improve prediction accuracy
* Adding offline support for rural communities
* Advanced maternal health analytics

---

# Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

* https://docs.flutter.dev/get-started/learn-flutter
* https://docs.flutter.dev/get-started/codelab
* https://docs.flutter.dev/reference/learning-resources

For help getting started with Flutter development, view the online documentation:

https://docs.flutter.dev/

It offers tutorials, samples, guidance on mobile development, and a full API reference.
