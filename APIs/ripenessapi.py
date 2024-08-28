# # class_labels = {1: "Cocoa Ripeness Stage 1", 2: "Cocoa Ripeness Stage 2", 3: "Cocoa Ripeness Stage 3", 4: "Cocoa Ripeness Stage4", 5: "Half-ripe Strawberry", 6: "Ripe Strawberry", 7: "Unripe Strawberry", 8: "Half-ripe Tomato", 9: "Ripe Tomato", 10: "Unripe Tomato"}  # Update with your class labels
# import io
# import torch
# import numpy as np
# from flask import Flask, request, jsonify, send_file
# from PIL import Image, ImageDraw
# import argparse
# import datetime
# import cv2
# import tensorflow as tf
# from re import DEBUG, sub
# from flask import Flask, render_template, request, redirect, send_file, url_for, Response, json
# from werkzeug.utils import secure_filename, send_from_directory
# import os
# import subprocess
# from subprocess import Popen
# import re
# import requests
# import shutil
# import time
# import glob
# from ultralytics import YOLO
# import base64

# app = Flask(__name__)

# # Load your YOLO model
# model = YOLO('models/best.pt')

# @app.route('/detect', methods=['POST'])
# def detect():
#     if 'image' not in request.files:
#         return jsonify({'error': 'No image provided'}), 400

#     file = request.files['image']

#     # If the user does not select a file, the browser may submit an empty part without a filename
#     if file.filename == '':
#         return jsonify({"error": "No selected file"}), 400

#     # Read the image in a way that OpenCV can process it
#     # Convert the image file to a numpy array
#     file_bytes = np.frombuffer(file.read(), np.uint8)

#     # Decode the image
#     img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
#     frame = cv2.imencode('.jpg', cv2.UMat(img))[1].tobytes()
#     image = Image.open(io.BytesIO(frame))    
#     # detections = model.predict(image, save=True, show = True)
     
#     results = model(image)  # results list

#     return results

#     #########################################################
#     # for r in results:
#     #     im_array = r.plot()  # plot a BGR numpy array of predictions
#     #     im = Image.fromarray(im_array[..., ::-1])  # RGB PIL image

#     # img_io = io.BytesIO()
#     # im.save(img_io, 'JPEG')
#     # img_io.seek(0)

#     # data_object = {}
#     # data_object["img"] = base64.b64encode(img_io.read()).decode('ascii')
    
#     # return json.dumps(data_object)

#     ###################################################################

#     # return send_file(img_io, mimetype='image/jpeg')

# if __name__ == '__main__':
#     app.run(debug=True)

# app.py
import io
import torch
import numpy as np
from flask import Flask, request, jsonify
from PIL import Image
import cv2
from ultralytics import YOLO
import base64

class_labels = {
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

class_colors = {
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

app = Flask(__name__)

# Load your YOLO model
model = YOLO('models/best.pt')

@app.route('/detect', methods=['POST'])
def detect():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    file_bytes = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
    image = Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))

    results = model(image)  # Perform detection

    #print(results)
    detection_results = []
    for result in results:
        for detection in result.boxes:
            class_id = int(detection.cls)
            color = class_colors.get(class_id, (255, 255, 255))  # Default to white if class not found
            detection_info = {
                'class': class_labels.get(class_id, 'Unknown'),
                'confidence': float(detection.conf),
                'box': detection.xyxy.tolist(),
                'color': color
            }
            detection_results.append(detection_info)

    #print(detection_results)

    return jsonify(detection_results)

if __name__ == '__main__':
    app.run(debug=True)


