from flask import Flask, request, make_response, send_file, redirect, jsonify
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import PriceForecast

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

class Test(Resource):
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

class GetPrediction(Resource):
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

api.add_resource(Test,'/')
api.add_resource(GetPrediction,'/getPrediction')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host='0.0.0.0', port=port)