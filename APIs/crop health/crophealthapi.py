
from flask import Flask, request, jsonify,redirect
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import joblib
import pandas as pd

# damages in dataset
crop_damage_mapping = {0:'Minimal Damage',1:'Partial Damage',2:'Significant Damage'}

# Load model and pipeline
model3 = joblib.load("APIs/crop health/crop_health.pkl")
pipeline2 = joblib.load("APIs/crop health/full_pipeline2.pkl")

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
            print("GOT POST")
            data = request.get_json()
            print(data)
            df = pd.DataFrame([data])#convert data to dataframe
            df = pipeline2.transform(df) #pipeline
            #model 
            prediction = model3.predict(df) 
            print("prediction: " )
            crop_damage = crop_damage_mapping[int(prediction)]  
            print("crop damage: ")
            # return predictions as json response
            return jsonify({
                'crop_damage': crop_damage
            })  
        except Exception as error:
            return {'error': str(error)}

api.add_resource(Test, '/')
api.add_resource(Predict, '/croppredict')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5002))
    app.run(host='0.0.0.0', port=port)