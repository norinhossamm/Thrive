# from flask import Flask, request, jsonify
# from flask_cors import CORS
# import base64

# app = Flask(__name__)
# CORS(app)  # Enable CORS for all routes

# @app.route('/upload', methods=['POST'])
# def upload_image():
#     print("GOT POST")
#     try:
#         if 'picture' not in request.files:
#             return jsonify({"error": "No file part"}), 400

#         file = request.files['picture']

#         if file.filename == '':
#             return jsonify({"error": "No selected file"}), 400

#         # Check if the file is an image (optional)
#         # if file.mimetype.split('/')[0] != 'image':
#         #     return jsonify({"error": "Not an image"}), 400

#         # Read and encode the image as base64
#         image_string = base64.b64encode(file.read()).decode('utf-8')
#         return jsonify({"image": image_string})
#     except Exception as e:
#         print("inside exception")
#         return jsonify({"error": str(e)}), 500

# @app.route('/alo', methods=['GET'])
# def yarab():
#     print("GOT GET")
#     return "hello deer"

# if __name__ == '__main__':
#     app.run(debug=True, port=5000)

# file: app.py
# file: app.py

from flask import Flask, send_file, abort
import os

app = Flask(__name__)

@app.route('/image', methods=['GET'])
def get_image():
    image_path = 'D:/UNI/GRAD PROJECT/MobileApp/assets/leaves.jpeg'  # Ensure this path is correct
    if os.path.exists(image_path):
        return send_file(image_path, mimetype='image/jpeg')
    else:
        abort(404, description="Resource not found")

if __name__ == '__main__':
    # Run the Flask server on all interfaces
    app.run(host='0.0.0.0', port=5000, debug=True)
