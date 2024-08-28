import io
import torch

import numpy as np
from flask import Flask, request, jsonify, redirect, make_response, send_file
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from PIL import Image
#########################
import cv2
from ultralytics import YOLO
import base64
##########################
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import joblib
import pandas as pd
##########################
import YieldForecast
################################
import PriceForecast
##########################
import requests


app = Flask(__name__)

# Load the pre-trained model with a try-except block to handle errors
try:
    LeafDisease_model = load_model('models/Resnet8020.h5')
    print(LeafDisease_model.summary())
except Exception as e:
    print(f"Error loading the model: {e}")

# Define the class labels
LeafDisease_class_labels = [
    "Tomato Bacterial Spot", "Tomato Late Blight", "Tomato Septoria Leaf Spot",
    "Tomato Spider Mites, Two Spotted Spider Mite", "Tomato Target Spot",
    "Tomato Yellow Leaf Curl Virus", "Tomato Early Blight", "Tomato Leaf Mold",
    "Tomato Mosaic Virus", "Healthy Tomato"
]

@app.route('/LeafDisease', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    # Get the image from the request
    imagefile = request.files['image']

    # Read the image file and convert it to a BytesIO object
    img_bytes = imagefile.read()
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")  # Convert image to RGB
    img = img.resize((224, 224))  # Assuming your model expects 224x224 images
    image = img_to_array(img)
    image = np.expand_dims(image, axis=0)
    image = preprocess_input(image)
    
    # Make predictions
    try:
        predictions = LeafDisease_model.predict(image)
        predicted_class_index = np.argmax(predictions[0])
        predicted_class_label = LeafDisease_class_labels[predicted_class_index]
        return jsonify({'prediction': predicted_class_label})
    except Exception as e:
        return jsonify({'error': 'Prediction failed', 'message': str(e)}), 500

####################################################################################################

Ripeness_model = YOLO('models/best.pt')

Ripeness_class_labels = {
    0: "Cocoa Ripeness Stage 1",
    1: "Cocoa Ripeness Stage 2",
    2: "Cocoa Ripeness Stage 3",
    3: "Cocoa Ripeness Stage4",
    4: "Half-ripe Strawberry",
    5: "Ripe Strawberry",
    6: "Unripe Strawberry",
    7: "Half-ripe Tomato",
    8: "Ripe Tomato",
    9: "Unripe Tomato"
}

Ripeness_class_colors = {
    0: (187, 237, 201),  # Red
    1: (239, 242, 65),  # Green
    2: (252, 173, 53),  # Blue
    3: (115, 85, 40),  # Yellow
    4: (255, 201, 221),  # Magenta
    5: (252, 35, 78),  # Cyan
    6: (252, 245, 35),  # Maroon
    7: (0, 255, 0),  # Olive
    8: (255, 0, 0),  # Dark Green
    9: (210, 242, 27)  # Purple
}


@app.route('/Ripeness', methods=['POST'])
def detect():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    file_bytes = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
    image = Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))

    results = Ripeness_model(image)  # Perform detection

    #print(results)
    detection_results = []
    for result in results:
        for detection in result.boxes:
            class_id = int(detection.cls)
            color = Ripeness_class_colors.get(class_id, (255, 255, 255))  # Default to white if class not found
            detection_info = {
                'class': Ripeness_class_labels.get(class_id, 'Unknown'),
                'confidence': float(detection.conf),
                'box': detection.xyxy.tolist(),
                'color': color
            }
            detection_results.append(detection_info)
    return jsonify(detection_results)
####################################################################################################
CropHealth_cors = CORS(app, resources={r"*": {"origins": "*"}})
CropHealth_api = Api(app)

# damages in dataset
crop_damage_mapping = {0:'Minimal Damage',1:'Partial Damage',2:'Significant Damage'}

# Load model and pipeline
CropHealth_model = joblib.load("APIs/crop health/crop_health.pkl")
CropHealth_pipeline = joblib.load("APIs/crop health/full_pipeline2.pkl")

#define test resource 
class CropHealthTest(Resource):
    def get(self):
        return 'Welcome to Test App API!'
    def post(self):
        try:
            value = request.get_json() #extract data from request
            if value:
                return {'Post Values': value}, 201 #data is found
            return {"error": "Invalid format."}  #data not found
        except Exception as error:
            return {'error': str(error)}

#define prediction class
class CropHealthPredict(Resource):
    def get(self):
        return {"error": "Invalid Method."}

    def post(self):
        try:
            print("GOT POST")
            data = request.get_json()
            print(data)
            df = pd.DataFrame([data])#convert data to dataframe
            df = CropHealth_pipeline.transform(df) #pipeline
            #model 
            prediction = CropHealth_model.predict(df) 
            print("prediction: " )
            crop_damage = crop_damage_mapping[int(prediction)]  
            print("crop damage: ")
            # return predictions as json response
            return jsonify({
                'crop_damage': crop_damage
            })  
        except Exception as error:
            return {'error': str(error)}

CropHealth_api.add_resource(CropHealthTest, '/testhealth')
CropHealth_api.add_resource(CropHealthPredict, '/CropHealth')
####################################################################################################

Yield_cors = CORS(app, resources={r"*": {"origins": "*"}})
Yield_api = Api(app)

class YieldTest(Resource):
    def get(self):
        return 'Welcome to, Yield Forecast API!'

    def post(self):
        try:
            value = request.get_json()
            if(value):
                return {'Post Values': value}, 201

            return {"error":"Invalid format."}

        except Exception as error:
            return {'error': error}

class GetYieldPrediction(Resource):
    def get(self): #We dont want GET
        return {"error":"Invalid Method."}

    def post(self): #We use the POST method
        try:

            data = request.get_json()
            start_date = data['start_date']
            end_date = data['end_date']

            print("yield predicting")
            # Call the forecast function to get the prediction
            predict = YieldForecast.forecast(start_date, end_date)
            print(predict)

             # Extract the graphs data and text from the prediction
            fgraph_data, forecast_data, forecast_title, hgraph_data, average_yield, max_yield, min_yield, pdf_content = predict

            # Prepare response JSON that displays all data
            response = {
                'forecast_graph_data': fgraph_data, #Daily Forecast area graph data
                'forecast_data': forecast_data, #Top 10 yields / All records 
                'forecast_title': forecast_title, #Title for forecast 
                'yield_history_graph_data': hgraph_data, #Yearly yield history graph data
                'average_yield': average_yield, #Average yield for date range
                'max_yield': max_yield,#Max yield for date range
                'min_yield': min_yield,#Min yield for date range
                'pdf_data': pdf_content  #Forecasted Content for PDF
            }
        
            # Return response
            return response, 200

        except Exception as error:
            return {'error': str(error)}

Yield_api.add_resource(YieldTest,'/testyield')
Yield_api.add_resource(GetYieldPrediction,'/Yield')
####################################################################################################

Price_cors = CORS(app, resources={r"*": {"origins": "*"}})
Price_api = Api(app)

class PriceTest(Resource):
    def get(self): #We dont want GET
        return 'Welcome to, Price Forecast API!'
    
    def post(self):
        try:
            value = request.get_json()
            if(value):
                return {'Post Values': value}, 201

            return {"error":"Invalid format."}

        except Exception as error:
            return {'error': error}

class GetPricePrediction(Resource):
    def get(self): #We dont want GET
        return {"error":"Invalid Method."}
    
    def post(self): #We use the POST method -> send data to server
        try:

            data = request.get_json() #capture data from postman
            start_date = data['start_date']
            end_date = data['end_date']

            # print(start_date)

            # Call the forecast function to get the prediction
            predict = PriceForecast.forecast(start_date, end_date)

            # Extract the Plotly graphs and text from the prediction
            fgraph_data, forecast_data, forecast_title, hgraph_data, average_FOB, max_FOB,min_FOB, pdf_content = predict

            # Prepare response JSON that displays all data
            response = {
                'forecast_graph_data': fgraph_data, #Daily Forecast area graph data
                'forecast_data': forecast_data, #Top 10 FOBs / All records 
                'forecast_title': forecast_title, #Title for forecast 
                'FOB_history_graph_data': hgraph_data, #Yearly FOB history graph data
                'average_FOB': average_FOB,
                'max_FOB': max_FOB,
                'min_FOB': min_FOB,
                'pdf_data': pdf_content  #Forecasted Content for PDF
            }
        
            # Return response
            return response, 200

        except Exception as error:
            return {'error': str(error)}

Price_api.add_resource(PriceTest,'/testprice')
Price_api.add_resource(GetPricePrediction,'/Price')
####################################################################################################

# Function to convert gs:// URL to HTTP URL
def convert_gs_to_http(gs_url):
    base_url = "https://firebasestorage.googleapis.com/v0/b/"
    parts = gs_url.replace("gs://", "").split("/", 1)
    bucket_name = parts[0]
    file_path = parts[1]
    file_path = file_path.replace("/", "%2F")  # Encode the path for URL
    return f"{base_url}{bucket_name}/o/{file_path}?alt=media"

# Firebase Storage gs:// URLs for the .pkl files
gs_crop_model_url = 'gs://agriculture-15db4.appspot.com/cropandfertilizerPKL/crop.pkl'
gs_fertilizer_model_url = 'gs://agriculture-15db4.appspot.com/cropandfertilizerPKL/fertilizer.pkl'
gs_pipeline_url = 'gs://agriculture-15db4.appspot.com/cropandfertilizerPKL/full_pipeline.pkl'

# Convert gs:// URLs to HTTP URLs
CROP_MODEL_URL = convert_gs_to_http(gs_crop_model_url)
FERTILIZER_MODEL_URL = convert_gs_to_http(gs_fertilizer_model_url)
PIPELINE_URL = convert_gs_to_http(gs_pipeline_url)

# Function to download file and load it into memory
def load_model_from_url(url):
    response = requests.get(url)
    response.raise_for_status()  # Check for request errors
    model = joblib.load(io.BytesIO(response.content))
    return model

# Load models and pipeline directly from URLs
try:
    crop_model = load_model_from_url(CROP_MODEL_URL)
    fertilizer_model = load_model_from_url(FERTILIZER_MODEL_URL)
    pipeline = load_model_from_url(PIPELINE_URL)
except Exception as e:
    raise ValueError(f"Failed to load model: {e}")

# Crops in dataset
crop_mapping = {
    0: 'Cotton', 1: 'Ginger', 2: 'Gram', 3: 'Grapes', 4: 'Groundnut', 5: 'Jowar',
    6: 'Maize', 7: 'Masoor', 8: 'Moong', 9: 'Rice', 10: 'Soybean', 11: 'Sugarcane',
    12: 'Tur', 13: 'Turmeric', 14: 'Urad', 15: 'Wheat'
}

# Fertilizers in dataset
fertilizer_mapping = {
    0: '10:10:10 NPK', 1: '10:26:26 NPK', 2: '12:32:16 NPK', 3: '13:32:26 NPK', 4: '18:46:00 NPK',
    5: '19:19:19 NPK', 6: '20:20:20 NPK', 7: '50:26:26 NPK', 8: 'Ammonium Sulphate', 9: 'Chelated Micronutrient',
    10: 'DAP', 11: 'Ferrous Sulphate', 12: 'Hydrated Lime', 13: 'MOP', 14: 'Magnesium Sulphate', 15: 'SSP',
    16: 'Sulphur', 17: 'Urea', 18: 'White Potash'
}

# Initialize Flask app
CF_cors = CORS(app, resources={r"*": {"origins": "*"}})
CF_api = Api(app)

#define test resource 
class CFTest(Resource):
    def get(self):
        return 'Welcome to Test App API!'
    def post(self):
        try:
            value = request.get_json() #extract data from request
            if value:
                return {'Post Values': value}, 201 #data is found
            return {"error": "Invalid format."}  #data not found
        except Exception as error:
            return {'error': str(error)}

#define prediction class
class CFPredict(Resource):
    def get(self):
        return {"error": "Invalid Method."}

    def post(self):
        try:
            data = request.get_json()
            df = pd.DataFrame([data]) #convert data to dataframe
            df = pipeline.transform(df) #pipeline
            #model crop
            prediction = crop_model.predict(df) 
            predicted_crop = crop_mapping[int(prediction)] 
            #model fertilizer
            prediction2 = fertilizer_model.predict(df) 
            predicted_fertilizer = fertilizer_mapping[int(prediction2)] 
            # return predictions as json response
            return jsonify({
                'predicted_crop': predicted_crop, 
                'predicted_fertilizer': predicted_fertilizer
            })  
        except Exception as error:
            return {'error': str(error)}

CF_api.add_resource(CFTest, '/testcf')
CF_api.add_resource(CFPredict, '/CropandFertilizer')






if __name__ == '__main__':
    app.run(port=5000, debug=True)