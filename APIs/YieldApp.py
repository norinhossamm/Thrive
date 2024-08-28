from flask import Flask, request, make_response, send_file, redirect, jsonify
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import YieldForecast

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

class Test(Resource):
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

class GetPredictionOutput(Resource):
    def get(self): #We dont want GET
        return {"error":"Invalid Method."}

    def post(self): #We use the POST method
        try:

            data = request.get_json()
            start_date = data['start_date']
            end_date = data['end_date']

            # Call the forecast function to get the prediction
            predict = YieldForecast.forecast(start_date, end_date)

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

api.add_resource(Test,'/')
api.add_resource(GetPredictionOutput,'/getPredictionOutput')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 6099))
    app.run(host='0.0.0.0', port=port)
