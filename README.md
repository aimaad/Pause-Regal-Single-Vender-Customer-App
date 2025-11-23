📱 Pause Regal – Single Vendor Customer App

Pause Regal – Single Vendor Customer App is a mobile application designed for customers to browse meals, place food orders, share their delivery location, and pay securely.
This app is part of the Pause Regal ecosystem, built to streamline food ordering and delivery for a single vendor.

🧩 Pause Regal Ecosystem

The full system includes:

🛠️ Vendor Admin Dashboard

Vendors manage dishes, prices, orders, and restaurant settings.

🚚 Delivery App

Delivery agents receive assigned orders and update delivery statuses.

🍽️ Customer App (this repository)

Customers browse meals, order food, and choose delivery addresses.

🚀 Features – Customer App
🛒 Order Meals

Browse vendor menu items

Product details (images, ingredients, pricing)

Add to cart and manage quantities

📍 Delivery Address

Customers can set their own delivery address

Integrated geolocation/map picker

Save multiple delivery addresses

💳 Integrated Payment

Secure built-in payment system

Automatic confirmation after payment success

🔔 Order Tracking

Real-time order status from preparation → delivery

🏗️ Tech Stack

Flutter (Dart)

Firebase (Authentication, APIs, Maps key configuration)

REST API backend for Pause Regal

Google Maps / Geolocation

Secure payment integration

📥 Installation & Setup
1️⃣ Clone the repository
git clone https://github.com/aimaad/Pause-Regal-Single-Vender-Customer-App
cd Pause-Regal-Single-Vender-Customer-App

2️⃣ Install dependencies
flutter pub get

🔑 Firebase Configuration (Required)

This app requires Firebase configuration for both Android and iOS, obtained directly from your Firebase project.

📱 Android Setup

Go to Firebase Console

Add your Android app

Download the generated file:
android/app/google-services.json

Place it in:

android/app/google-services.json

🍏 iOS Setup

Add your iOS app in Firebase Console

Download the file:
ios/Runner/GoogleService-Info.plist

Place it in:

ios/Runner/GoogleService-Info.plist

🌍 Google Maps API Keys

Make sure to enable:

Maps SDK for Android

Maps SDK for iOS

Then configure:

For Android

Add your API key inside:
android/app/src/main/AndroidManifest.xml

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_MAPS_API_KEY"/>

For iOS

In ios/Runner/AppDelegate.swift :

GMSServices.provideAPIKey("YOUR_IOS_MAPS_API_KEY")

▶️ Run the project
flutter run
