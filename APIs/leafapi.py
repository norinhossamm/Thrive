import io
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input
from tensorflow.keras.preprocessing.image import load_img, img_to_array

from PIL import Image

app = Flask(__name__)

# Load the pre-trained model
model = load_model('models/Resnet8020.h5')
print(model.summary())
print("Model Output Names:", model.output_names)

#class_labels = ["Tomato_healthy", "Tomato_Late_blight", "Tomato_Septoria_leaf_spot", "Tomato__Tomato_YellowLeaf__Curl_Virus", "Tomato_Bacterial_spot", "Tomato___Early_blight", "Tomato_Spider_mites_Two_spotted_spider_mite", "Tomato___Leaf_Mold", "Tomato___Tomato_mosaic_virus", "Tomato__Target_Spot"]
class_labels = ["Tomato Bacterial Spot", "Tomato Late Blight", "Tomato Septoria Leaf Spot", "Tomato Spider Mites, Two Spotted Spider Mite", "Tomato Target Spot", "Tomato Yellow Leaf Curl Virus", "Tomato Early Blight", "Tomato Leaf Mold", "Tomato Mosaic Virus", "Healthy Tomato"]

@app.route('/predict', methods=['POST'])
def predict():
    print("hello")  # Print "hello" whenever a POST request is received

    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    # Get the image from the request
    imagefile = request.files['image']

    
    # Read the image file and convert it to a BytesIO object
    img_bytes = imagefile.read()
    img = Image.open(io.BytesIO(img_bytes))
    img = img.resize((224, 224))  # Assuming your model expects 224x224 images
    image = img_to_array(img)
    image = np.expand_dims(image, axis=0)
    image = preprocess_input(image)
#####################################################################################
 
    # Make predictions
    predictions = model.predict(image)
    print(predictions)
    # Get the predicted class index
    predicted_class_index = np.argmax(predictions[0])
    print(predicted_class_index)
    
    # Get the corresponding class label
    predicted_class_label = class_labels[predicted_class_index]
    print(predicted_class_label)
    print("Prediction:", predicted_class_label)
    # Pass the prediction to the template
    prediction = predicted_class_label
#####################################################################################
    # Return prediction result
    return jsonify({'prediction': prediction})

if __name__ == '__main__':
    app.run(debug=True)
