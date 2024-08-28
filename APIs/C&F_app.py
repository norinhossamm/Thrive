from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import joblib
import pandas as pd
import requests
import io

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
app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

#define test resource 
class Test(Resource):
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
class Predict(Resource):
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

api.add_resource(Test, '/')
api.add_resource(Predict, '/predict')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 6000))
    app.run(host='0.0.0.0', port=port)
