# Thrive

'Thrive' is a user-friendly mobile application designed to assist agricultural business owners and farmers in precision planning and enhancing sustainability. It features a time-series forecast for yield and price, a crop and fertilizer recommendation system, fruit ripeness detection, leaf disease classification, and crop health assessment based on environmental factors. 

**Technologies used**: LSTM - GRU - XgBoost - YOLOv8 - ResNet50 - Flutter - Flask API - Firebase Firestore 

## Key Features:

#### 1. Role-Based Access

- The 'Thrive' app provides a secure login system that differentiates users based on roles—Farmer, Owner, and Admin.
  
- Firebase Authentication: Login and sign-up processes are powered by Firebase Authentication, providing enhanced security and data protection for all users.

- Login Interface: Each user type is directed to a personalized login page for entering their credentials securely.

- Sign-Up Option: New users can easily create an account by providing necessary details like name, email, phone number, National ID, and password, all managed securely through Firebase.

<div align=center>
<img width="698" alt="Screenshot 2024-08-28 at 7 02 16 PM" src="https://github.com/user-attachments/assets/89258546-5f83-4dbf-a66a-d945b8f741bf">
</div>


#### 2. App UI 

- Upon logging into the 'Thrive' app, users are directed to a dashboard where they can select their specific farm from a dropdown menu. Depending on the user role, different AI-based services are available:
  
  - Owner Access: The owner has full access to all three AI-based services:
  
    - Decision Support System (DSS): Provides Yield&Price forecasts and recommendations for crop and fertilizer selection based on environmental data.
      
    - Vision System: Uses computer vision for fruit ripeness detection and leaf disease classification.
      
    - Crop Health: Analyzes environmental factors to assess and classify crop health.
      
<div align=center>
<img width="246" alt="Screenshot 2024-08-28 at 7 17 59 PM" src="https://github.com/user-attachments/assets/445abcef-b97e-41b5-ad21-08828df38c8c">
</div>
      
  - Farmer Access: The farmer can access two services:
    
    - Vision System and Crop Health, which are essential for day-to-day farming activities, such as monitoring crop conditions and identifying diseases.
      
  - Admin Role: The admin is responsible for data entry, ensuring the system is updated with accurate and current information to support these AI functionalities.

<div align=center>
<img width="688" alt="Screenshot 2024-08-28 at 7 08 26 PM" src="https://github.com/user-attachments/assets/4e1508cc-ff68-41b8-a162-f208b1d8dd66">
</div>

#### 3. Yield & Price Forecasts:

-  Yield and Price Forecasting Feature: Allows users to select either yield or price forecast for specific crops (e.g., strawberries) and define the desired forecast period.
  
-  Forecast Graph: Displays a visual graph of forecasted yield or price trends over the selected time frame, providing insights into expected changes.
  
-  Top 10 Forecasts: Lists the top 10 forecasted values for easier interpretation and decision-making.
  
-  Daily Yield Report: Generates a downloadable PDF report detailing daily yield data, including average, maximum, and minimum values, for comprehensive analysis and planning.
  
  <div align=center>
  <img width="683" alt="Screenshot 2024-08-28 at 7 20 56 PM" src="https://github.com/user-attachments/assets/5dae73f7-ca3c-433b-b735-41f4334f1a98">
  </div>

  #### 4. Crop & Fertilizer Recommendation:

- Crop and Fertilizer Recommendation Feature: Users input various parameters such as district name, soil color, nitrogen, phosphorus, potassium levels, pH, rainfall, and temperature.
  
- AI-Powered Output: Based on the provided data, the system uses a machine learning model to suggest the most suitable crop and fertilizer combination.
  
- Result Display: The app shows the recommended crop and fertilizer, allowing users to save the prediction in the database for future reference.

<div align=center>
<img width="669" alt="Screenshot 2024-08-28 at 7 24 59 PM" src="https://github.com/user-attachments/assets/b3d30358-363c-45a8-8d5d-5cc243463dc4">
</div>

 #### 5. Crop Health Prediction:

- Crop Health Prediction: Users input parameters like insect count, crop type, soil type, pesticide use, and season.
  
- AI Analysis: The system predicts crop health and potential damage levels.
  
- Result Display: Shows the damage level (e.g., minimal damage) and allows users to save the prediction.
  
  <div align=center>
  <img width="689" alt="Screenshot 2024-08-28 at 7 28 49 PM" src="https://github.com/user-attachments/assets/d8ce4434-be67-482e-9b27-10b26d59ff68">
  </div>

 #### 6. Automated Crop Inspection:
 
 - Automated Crop Inspection: Allows users to upload or take a picture of crops directly within the app.
   
 - Image Analysis: Uses AI models to detect fruit ripeness levels and classify leaf diseases from the uploaded images.
   
 - Results Display: Provides immediate feedback on crop status, such as ripeness stage or specific leaf disease (e.g., Tomato Early Blight).

  <div align=center>
  <img width="686" alt="Screenshot 2024-08-28 at 7 33 56 PM" src="https://github.com/user-attachments/assets/7b1ed67f-3f78-4bfd-ad8a-76152fe0e2a6">
  </div>
