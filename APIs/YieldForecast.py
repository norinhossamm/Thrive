import pandas as pd
import tensorflow as tf
import numpy as np

#Convert dataframe to x and y np arrays function
def df_to_X_y3(df, window_size):
    df_as_np = df.to_numpy()
    X = []
    y = []
    for i in range(len(df_as_np) - window_size):
        row = [r for r in df_as_np[i:i + window_size]]
        X.append(row)
        label = df_as_np[i + window_size][0]
        y.append(label)
    return np.array(X), np.array(y)

#Function for forecasting
def forecast(user_start_date, user_end_date): #Parameters: Take from user the input data which is date range  

    print("forecasting")
    weather_yieldata = pd.read_csv('D:/UNI/GRAD PROJECT/MobileApp/models/Yield_extended_concatenatedf.csv')
    weather_yieldata.set_index('Date', inplace=True)
    weather_yieldata.index = pd.to_datetime(weather_yieldata.index)

    # Convert the transformed data to X and y arrays
    window_size=90 # Consider the past 90 historical weather and yield to predict future yields
    X3, y3 = df_to_X_y3(weather_yieldata, window_size)
  
    # Prepare input for model to predict on [The window from 2022 to be used as historical input to the model]
    train_size = int(0.8 * len(X3))
    X_input = X3[train_size:]
    
    print("still forecasting")
    # Load the LSTM model from the saved h5 file
    try:
        # Load the LSTM model from the saved h5 file
        model_filename = "D:/UNI/GRAD PROJECT/MobileApp/models/trained_model.h5"
        model = tf.keras.models.load_model(model_filename)
        print("model loaded successfully")
    except Exception as e:
        print(f"Error loading model: {e}")
        return
    
    try:
        # Predict on X_input
        X_input = np.array(X_input, dtype=np.float32)
        input_predictions = model.predict(X_input).flatten()
        input_predictions = input_predictions.round(2)
        print("prediction done")
    except Exception as e:
        print(f"Error during prediction: {e}")
        return
    
    # Take last 731 points from predictions on the input data [your 2023, 2024 forecast]
    forecast_df = pd.DataFrame({'Yield': input_predictions[-731:]})

    # Add dates starting from January 1, 2023 along with forecasted values [Forecasting period]
    user_start_date = pd.to_datetime(user_start_date)
    user_end_date = pd.to_datetime(user_end_date)
    start_date = pd.to_datetime('2023-01-01')
    end_date = start_date + pd.Timedelta(days=730)  # Adjusted to match the length of predictions
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    # Assign dates to the DataFrame
    forecast_df['Date'] = dates

    #Based on user input - start and end date
    #Filter the DataFrame based on user input date range
    filtered_df = forecast_df[(forecast_df['Date'] >= user_start_date) & (forecast_df['Date'] <= user_end_date)]
    date_range = pd.date_range(start=user_start_date, end=user_end_date, freq='D')
    months_difference = len(pd.date_range(start=date_range.min(), end=date_range.max(), freq='M'))
    date_difference_days = len(date_range)

    # Check if the date range is greater than 3 months, if so display graph weekly format for easier interpretation!
    if months_difference >= 3:
        # Aggregate the data to weekly frequency
        filtered_weekly = filtered_df.resample('W', on='Date').mean().reset_index()

        x = filtered_weekly['Date']
        day_month = x.dt.strftime('%d %b') 
        y = filtered_weekly['Yield']

        # Generate week numbers
        week_numbers = (filtered_weekly['Date'].dt.day // 7 + 1).astype(str)

        # Generate month and week text
        if user_start_date.year != user_end_date.year:
            month_week_text = filtered_weekly['Date'].dt.strftime('%b %Y, Week ') + week_numbers
        else:
            month_week_text = filtered_weekly['Date'].dt.strftime('%b Week ') + week_numbers
        
        fgraph_data = {
            'daymonth': day_month.tolist(),  # List of day, month values
            'tooltip': month_week_text.tolist(), #List of month and its week number for tooltip in graph
            'yield': y.tolist()      # List of yield values
        }
    else:
        x = filtered_df['Date']
        day_month = x.dt.strftime('%d %b')
        y = filtered_df['Yield']

        if user_start_date.year != user_end_date.year:
            tooltip_date = x.dt.strftime('%d %b %Y')
        else:
            tooltip_date = day_month
        
        fgraph_data = {
            'daymonth': day_month.tolist(),  # List of day, month values
            'tooltip': tooltip_date.tolist(),
            'yield': y.tolist()      # List of yield values
        }

    #2. "Best 10 yields" OR all records depending on condition
    #Check date range if less than or equal to 10 days => all records displayed ELSE top 10 yields 
    #Print all records, NO BEST  "- day forecast", returns list of dictionaries 
    if date_difference_days <= 10:
        forecast_title = f"{date_difference_days} day forecast"
        forecast_data = []
        for index, row in filtered_df.iterrows():
            if isinstance(row['Date'], str):
                date_value = pd.to_datetime(row['Date'])
            else:
                date_value = row['Date']
            formatted_date = date_value.strftime('%A, %B %d')  # Format the date 
            if user_start_date.year != user_end_date.year:
                formatted_date += f", {date_value.year}"  # Add year if start and end dates have different years
            forecasted_value_rounded = round(row['Yield'], 2)  # Round forecasted value to 2 decimal place
            forecast_data.append({'Date': formatted_date, 'Yield': forecasted_value_rounded})
    else:
        # Get the top 10 forecasted values - "Top 10 Forecasts", returns list of dictionaries 
        forecast_title = "Top 10 forecasts"
        top_10_forecasts = filtered_df.nlargest(10, 'Yield')

        forecast_data = []
        for index, row in top_10_forecasts.iterrows():
            if isinstance(row['Date'], str):
                date_value = pd.to_datetime(row['Date'])
            else:
                date_value = row['Date']
            formatted_date = date_value.strftime('%A, %B %d')  # Format the date 
            if user_start_date.year != user_end_date.year:
                formatted_date += f", {date_value.year}"  # Add year if start and end dates have different years
            forecasted_value_rounded = round(row['Yield'], 2)  # Round forecasted value to 2 decimal place
            forecast_data.append({'Date': formatted_date, 'Yield': forecasted_value_rounded})


    # 3. Line graph content  - Title: "Yield History"
    #Statistics: for comparsion - yield - bar to avg yearly yield up to 2023 
    mean_yield_per_year = weather_yieldata.groupby(weather_yieldata.index.year)['Pounds/Acre_smoothed'].mean()
    # Create a DataFrame with the mean yield per year
    mean_yield_df = mean_yield_per_year.reset_index()
    mean_yield_df.columns = ['Year', 'Mean Yield']
    # Format the 'Mean Yield' column to display two decimal place
    mean_yield_df['Mean Yield'] = mean_yield_df['Mean Yield'].round(2)
    mean_yield_df['Year'] = mean_yield_df['Year'].astype(str)  # Ensure 'Year' column is of string data type
    mean_yield_df_excl_2024 = mean_yield_df[mean_yield_df['Year'] != '2024']  # Compare with string '2023'
    # Convert 'Mean Yield' column back to float if necessary
    hgraph_data = {
        'Year': mean_yield_df_excl_2024['Year'].tolist(),
        'Mean Yield': mean_yield_df_excl_2024['Mean Yield'].tolist()  # No need to convert to float again
    }

    #4. Statistics: Average, maximum, minimum 
    average_yield = filtered_df['Yield'].mean()
    max_yield = filtered_df['Yield'].max()
    min_yield = filtered_df['Yield'].min()
    average_yield= float(average_yield)
    max_yield = float(max_yield)
    min_yield= float(min_yield)

    #5. Content that will be added to PDF in flutter
    filtered_data = []
    for index, row in filtered_df.iterrows():
        formatted_date = row['Date'].strftime('%d/%m/%Y')  # Format the date 
        yield_value_rounded = round(row['Yield'], 2)  # Round yield value to 2 decimal place
        filtered_data.append({'Date': formatted_date, 'Yield': yield_value_rounded})

    return fgraph_data, forecast_data, forecast_title, hgraph_data, average_yield, max_yield, min_yield, filtered_data





