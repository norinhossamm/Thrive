import pandas as pd
import tensorflow as tf
import numpy as np
import joblib
import plotly.express as px
import plotly.graph_objects as gopl
from plotly.subplots import make_subplots
from datetime import datetime
from sklearn.preprocessing import MinMaxScaler

#Convert dataframe to x and y np arrays function
def df_to_X_y(df, window_size=5):
    df_as_np = df.to_numpy()
    X = []
    y = []
    for i in range(len(df_as_np)-window_size):
        row = [[a] for a in df_as_np[i:i+window_size]]
        X.append(row)
        label = df_as_np[i+window_size]
        y.append(label)
    return np.array(X), np.array(y)

#Function for forecasting
def forecast(user_start_date, user_end_date): #Parameters: Take from user the input data which is date range  

    year = user_start_date.split("-")[0]
    # print(year)
    
    # Load and transform the dataset using the saved pipeline
    transformed_data = pd.read_csv('D:/UNI/GRAD PROJECT/MobileApp/models/Price_output.csv')
    transformed_data.loc[:, 'Date'] = pd.to_datetime(transformed_data['Date'])
    transformed_data.set_index('Date', inplace=True)
    if(year == '2023'):

        # Convert the transformed data to X and y arrays
        window_size=5
        X1, y1 = df_to_X_y(transformed_data, window_size)

        # Split data into train and test sets
        X_train1, y_train1 = X1[:3400], y1[:3400]
        X_val1, y_val1 = X1[3400:3651], y1[3400:3651]
        X_test1, y_test1 = X1[3651:], y1[3651:]
        
        # Load the LSTM model from the saved h5 file
        model_filename = "D:/UNI/GRAD PROJECT/MobileApp/models/Price_Forecasting2023.h5"
        model = tf.keras.models.load_model(model_filename)
        print("TensorFlow version:", tf.__version__)
        
        # Predict on X_test
        test_predictions3 = model.predict(X_test1).flatten()
        test_predictions3 = test_predictions3.round(2)
        # print(len(test_predictions3))
        
        # Take last 365 points of predictions [your 2023 forecast]
        forecast_df = pd.DataFrame({'FOB': test_predictions3})

        # Add dates starting from January 1, 2023 along with forecasted values
        start_date = pd.to_datetime('2023-01-01')
        end_date = start_date + pd.Timedelta(days=358)  # Adjusted to match the length of test_predictions
        dates = pd.date_range(start=start_date, end=end_date, freq='D')
        # Assign dates to the DataFrame
        forecast_df['Date'] = dates
        # print(forecast_df)

        #Based on user input - start and end date
        #Filter the DataFrame based on user input date range
        filtered_df = forecast_df[(forecast_df['Date'] >= user_start_date) & (forecast_df['Date'] <= user_end_date)]
        # print(filtered_df)
        date_range = pd.date_range(start=user_start_date, end=user_end_date, freq='D')
        # print(date_range)
        months_difference = len(pd.date_range(start=date_range.min(), end=date_range.max(), freq='M'))
        # print(months_difference)
        date_difference_days = len(date_range)

        # Check if the date range is greater than 3 months, if so display graph weekly format for easier interpretation!
        if months_difference >= 3:
            # Aggregate the data to weekly frequency
            filtered_weekly = filtered_df.resample('W', on='Date').mean().reset_index()

            x = filtered_weekly['Date']
            day_month = x.dt.strftime('%d %b') #hover
            y = filtered_weekly['FOB']

            # Generate week numbers
            week_numbers = (filtered_weekly['Date'].dt.day // 7 + 1).astype(str)

            # Generate month and week text
            month_week_text = filtered_weekly['Date'].dt.strftime('%b Week ') + week_numbers

            fgraph_data = {
                'daymonth': day_month.tolist(),  # List of day, month values
                'tooltip': month_week_text.tolist(), #List of month and its week number for tooltip in graph
                'FOB': y.tolist()      # List of FOB values
            }

            # print(fgraph_data)

        else:
                x = filtered_df['Date']
                day_month = x.dt.strftime('%d %b')
                y = filtered_df['FOB']

                fgraph_data = {
                    'daymonth': day_month.tolist(),  # List of day, month values
                    'tooltip': day_month.tolist(),
                    'FOB': y.tolist()      # List of FOB
                }



        #2. "Best 10 FOBs" OR all records depending on condition
        #Check date range if less than or equal to 10 days => all records displayed ELSE top 10 FOBs 
        #Print all records, NO BEST  "- day forecast", returns list of dictionaries 
        if date_difference_days <= 10:
            forecast_title = f"{date_difference_days} day forecast"
            forecast_data = []
            for index, row in filtered_df.iterrows():
                formatted_date = row['Date'].strftime('%A, %B %d')  # Format the date 
                forecasted_value_rounded = round(row['FOB'], 2)  # Round forecasted value to 2 decimal place
                forecast_data.append({'Date': formatted_date, 'FOB': forecasted_value_rounded})

        # print(forecast_data)

        else:
            # Get the top 10 forecasted values - "Top 10 Forecasts", returns list of dictionaries 
            forecast_title = "Top 10 forecasts"
            top_10_forecasts = filtered_df.nlargest(10, 'FOB')
            for index, row in top_10_forecasts.iterrows():
                formatted_date = row['Date'].strftime('%d %b, %Y')  

            forecast_data = []
            for index, row in top_10_forecasts.iterrows():
                formatted_date = row['Date'].strftime('%A, %B %d')  # Format the date 
                forecasted_value_rounded = round(row['FOB'], 2)  # Round forecasted value to 2 decimal place
                forecast_data.append({'Date': formatted_date, 'FOB': forecasted_value_rounded})

        # print(forecast_data)

        # 3. Line graph content  - Title: "FOB History"
        #Statistics: for comparsion - FOB - bar to avg yearly FOB up to 2023 
        mean_FOB_per_year = transformed_data.groupby(pd.Grouper(freq='Y'))['FOB Per Pound'].mean() #FOB Per Pound
        mean_FOB_per_year.index = pd.to_datetime(mean_FOB_per_year.index).year
        # print(mean_FOB_per_year)
        # mean_yield_per_year = transformed_data.groupby(transformed_data.index.year)['Pounds/Acre_smoothed'].mean()
        # Create a DataFrame with the mean FOB per year
        mean_FOB_df = mean_FOB_per_year.reset_index()
        mean_FOB_df.columns = ['Year', 'Mean FOB']
        # print(mean_FOB_df)
        # Format the 'Mean FOB' column to display two decimal place
        mean_FOB_df['Mean FOB'] = mean_FOB_df['Mean FOB'].round(2)
        mean_FOB_df['Year'] = mean_FOB_df['Year'].astype(str)  # Ensure 'Year' column is of string data type
        # Convert 'Mean FOB' column back to float if necessary
        hgraph_data = {
            'Year': mean_FOB_df['Year'].tolist(),
            'Mean FOB': mean_FOB_df['Mean FOB'].tolist()
        }

        # print(hgraph_data)

        average_FOB = filtered_df['FOB'].mean()
        max_FOB = filtered_df['FOB'].max()
        min_FOB = filtered_df['FOB'].min()
        average_FOB= float(average_FOB)
        max_FOB = float(max_FOB)
        min_FOB= float(min_FOB)

        #4. Content that will be converted to PDF in flutter
        filtered_data = []
        for index, row in filtered_df.iterrows():
            formatted_date = row['Date'].strftime('%d/%m/%Y')  # Format the date 
            FOB_value_rounded = round(row['FOB'], 2)  # Round FOB value to 2 decimal place
            filtered_data.append({'Date': formatted_date, 'FOB': FOB_value_rounded})

    else:
        # print(year)
        # Load the LSTM model from the saved h5 file
        model_filename = "D:/UNI/GRAD PROJECT/MobileApp/models/Price_Forecasting2024.h5"
        model = tf.keras.models.load_model(model_filename)
        print("TensorFlow version:", tf.__version__)

        #scaling
        scaler = MinMaxScaler()
        train_reshaped = transformed_data.values.reshape(-1, 1)
        scaler.fit(train_reshaped)
        scaled_train = scaler.transform(train_reshaped)

        #input to model
        first_eval_batch = scaled_train[-5:]
        current_batch = first_eval_batch.reshape((1, 5, 1))

        # #length of the duration
        # start_date = datetime.strptime(user_start_date, "%Y-%m-%d")
        # end_date = datetime.strptime(user_end_date, "%Y-%m-%d")
        # time_length = end_date - start_date

        # Predict
        predictions = []
        for i in range(365):

            # get the prediction value for the first batch
            current_pred = model.predict(current_batch)[0]

            # append the prediction into the array
            predictions.append(current_pred)

            # use the prediction to update the batch and remove the first value
            current_batch = np.append(current_batch[:,1:,:],[[current_pred]],axis=1)

        # print(predictions)
        true_predictions = scaler.inverse_transform(predictions)
        true_predictions = np.round(true_predictions, 2)
        # print(true_predictions)

        forecast_df = pd.DataFrame(true_predictions)
        # Create a date range starting from 2024-01-01
        date_range = pd.date_range(start='2024-01-01', periods=len(true_predictions), freq='D')
        forecast_df['Date'] = date_range
        forecast_df.rename(columns={0: 'FOB'}, inplace=True)
        # forecast_df.index = date_range

        print(forecast_df)


        #Based on user input - start and end date
        #Filter the DataFrame based on user input date range
        filtered_df = forecast_df[(forecast_df['Date'] >= user_start_date) & (forecast_df['Date'] <= user_end_date)]
        # print(filtered_df)
        date_range = pd.date_range(start=user_start_date, end=user_end_date, freq='D')
        # print(date_range)
        months_difference = len(pd.date_range(start=date_range.min(), end=date_range.max(), freq='M'))
        # print(months_difference)
        date_difference_days = len(date_range)
        # print(len(date_range))

        # Check if the date range is greater than 3 months, if so display graph weekly format for easier interpretation!
        if months_difference >= 3:
            # Aggregate the data to weekly frequency
            filtered_weekly = filtered_df.resample('W', on='Date').mean().reset_index()
            filtered_weekly = np.round(filtered_weekly, 2)

            x = filtered_weekly['Date']
            day_month = x.dt.strftime('%d %b') #hover
            y = filtered_df['FOB']

            # Generate week numbers
            week_numbers = (filtered_weekly['Date'].dt.day // 7 + 1).astype(str)

            # Generate month and week text
            month_week_text = filtered_weekly['Date'].dt.strftime('%b Week ') + week_numbers

            fgraph_data = {
                'daymonth': day_month.tolist(),  # List of day, month values
                'tooltip': month_week_text.tolist(), #List of month and its week number for tooltip in graph
                'FOB': y.tolist()      # List of FOB values
            }

            print(fgraph_data)

        else:
                x = filtered_df['Date']
                day_month = x.dt.strftime('%d %b')
                y = filtered_df['FOB']

                fgraph_data = {
                    'daymonth': day_month.tolist(),  # List of day, month values
                    'tooltip': day_month.tolist(),
                    'FOB': y.tolist()      # List of FOB
                }

                # print(fgraph_data)

        #2. "Best 10 FOBs" OR all records depending on condition
        #Check date range if less than or equal to 10 days => all records displayed ELSE top 10 FOBs 
        #Print all records, NO BEST  "- day forecast", returns list of dictionaries 
        if date_difference_days <= 10:
            forecast_title = f"{date_difference_days} day forecast"
            forecast_data = []
            for index, row in filtered_df.iterrows():
                formatted_date = row['Date'].strftime('%A, %B %d')  # Format the date 
                forecasted_value_rounded = round(row['FOB'], 2)  # Round forecasted value to 2 decimal place
                forecast_data.append({'Date': formatted_date, 'FOB': forecasted_value_rounded})


        else:
            # Get the top 10 forecasted values - "Top 10 Forecasts", returns list of dictionaries 
            forecast_title = "Top 10 forecasts"
            top_10_forecasts = filtered_df.nlargest(10, 'FOB')
            for index, row in top_10_forecasts.iterrows():
                formatted_date = row['Date'].strftime('%d %b, %Y')  

            forecast_data = []
            for index, row in top_10_forecasts.iterrows():
                formatted_date = row['Date'].strftime('%A, %B %d')  # Format the date 
                forecasted_value_rounded = round(row['FOB'], 2)  # Round forecasted value to 2 decimal place
                forecast_data.append({'Date': formatted_date, 'FOB': forecasted_value_rounded})

        # print(forecast_data)

        # 3. Line graph content  - Title: "FOB History"
        #Statistics: for comparsion - FOB - bar to avg yearly FOB up to 2023 
        mean_FOB_per_year = transformed_data.groupby(pd.Grouper(freq='Y'))['FOB Per Pound'].mean() #FOB Per Pound
        mean_FOB_per_year.index = pd.to_datetime(mean_FOB_per_year.index).year
        # print(mean_FOB_per_year)
        # mean_yield_per_year = transformed_data.groupby(transformed_data.index.year)['Pounds/Acre_smoothed'].mean()
        # Create a DataFrame with the mean FOB per year
        mean_FOB_df = mean_FOB_per_year.reset_index()
        mean_FOB_df.columns = ['Year', 'Mean FOB']
        # print(mean_FOB_df)
        # Format the 'Mean FOB' column to display two decimal place
        mean_FOB_df['Mean FOB'] = mean_FOB_df['Mean FOB'].round(2)
        mean_FOB_df['Year'] = mean_FOB_df['Year'].astype(str)  # Ensure 'Year' column is of string data type
        # Convert 'Mean FOB' column back to float if necessary
        hgraph_data = {
            'Year': mean_FOB_df['Year'].tolist(),
            'Mean FOB': mean_FOB_df['Mean FOB'].tolist()
        }

        print(hgraph_data)

        average_FOB = filtered_df['FOB'].mean()
        max_FOB = filtered_df['FOB'].max()
        min_FOB = filtered_df['FOB'].min()
        average_FOB= float(average_FOB)
        max_FOB = float(max_FOB)
        min_FOB= float(min_FOB)

        #4. Content that will be converted to PDF in flutter
        filtered_data = []
        for index, row in filtered_df.iterrows():
            formatted_date = row['Date'].strftime('%d/%m/%Y')  # Format the date 
            FOB_value_rounded = round(row['FOB'], 2)  # Round FOB value to 2 decimal place
            filtered_data.append({'Date': formatted_date, 'FOB': FOB_value_rounded})

    return fgraph_data, forecast_data, forecast_title, hgraph_data,average_FOB, max_FOB,min_FOB, filtered_data