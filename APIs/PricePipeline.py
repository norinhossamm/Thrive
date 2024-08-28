import pandas as pd
import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import FunctionTransformer
from joblib import dump

# Custom transformer to select specific columns 
class ColumnSelector(BaseEstimator, TransformerMixin):
    def __init__(self, columns):
        self.columns = columns

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X[self.columns]
    
# Custom transformer to convert date to datetime and set it as index
class DateConverter(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X.reset_index(inplace=True)
        # print(X.index.dtype)
        X.loc[:, 'Date'] = pd.to_datetime(X['Date'])
        X = X.loc[:, X.columns != 'index']
        X.set_index('Date', inplace=True)
        # print(X.index.dtype)
        return X

# Custom transformer to filter out 2013 year
class YearFilter(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X[X.index.year != 2013]
    
#resample a pandas DataFrame with a datetime index to daily frequency ('D')
class ResampleTransformer(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X.resample('D').asfreq()

# Custom transformer for linear interpolation
class InterpolateTransformer(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X['FOB Per Pound'] = X['FOB Per Pound'].replace('[\$,]', '', regex=True).astype(float)
        return X['FOB Per Pound'].interpolate()
    
# Custom transformer for moving average smoothing with window size 10
class MovingAverageTransformer(BaseEstimator, TransformerMixin):    
        def __init__(self, window_size=5):
            self.window_size = window_size

        def fit(self, X, y=None):
            return self

        def transform(self, X):
            df_as_np = X.to_numpy()
            x = []
            y = []
            window=self.window_size
            for i in range(len(df_as_np)-window):
                row = [[a] for a in df_as_np[i:i+window]]
                x.append(row)
                label = df_as_np[i+window]
                y.append(label)

            values_2d = np.reshape(x, (4010, 5))
            return values_2d


# Create the pipeline with the defined transformers
pipeline = Pipeline([
    ('column_selector', ColumnSelector(columns=['Date','FOB Per Pound'])),
    ('date_converter', DateConverter()),
    # ('year_filter', YearFilter()),
    ('resample', ResampleTransformer()),  
    ('interpolate', InterpolateTransformer()),
    # ('moving_average', MovingAverageTransformer())
])

# Load and preprocess the data using the pipeline
data = pd.read_csv('D:/AAST term10/Grad Project/pricing.csv')
# print(data)
preprocessedata = pipeline.fit_transform(data)


# Convert preprocessed data to a DataFrame for printing check
preprocessed_df = pd.DataFrame(preprocessedata)
print(preprocessed_df)

# Save the pipeline to a file
pipeline_filename = 'D:/AAST term10/Grad Project/pipeline2023.pkl'
dump(pipeline, pipeline_filename)
print("Pipeline saved successfully to:", pipeline_filename)