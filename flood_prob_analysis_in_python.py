# Import necessary libraries
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import r2_score
import statsmodels.api as sm

# Load the data
train_data = pd.read_csv('train.csv')
test_data = pd.read_csv('test.csv')

# Split the data
train_data, valid_data = train_test_split(train_data, test_size=0.3, random_state=42)

# Prepare the data for linear regression
y_train = train_data['FloodProbability']
X_train = train_data.drop(['FloodProbability', 'id'], axis=1)
X_train = sm.add_constant(X_train)

# Linear Regression
model = sm.OLS(y_train, X_train).fit()
print(model.summary())

# Correlation analysis
cor_matrix = train_data.corr()
target_correlations = cor_matrix['FloodProbability'].drop('FloodProbability')
print(target_correlations)

# Polynomial Regression
poly = PolynomialFeatures(degree=2)
X_train_poly = poly.fit_transform(X_train)
poly_model = LinearRegression().fit(X_train_poly, y_train)
poly_predictions = poly_model.predict(X_train_poly)
print(f"Polynomial Regression R^2: {r2_score(y_train, poly_predictions)}")

# Cross-Validation Linear Regression
cross_val_model = LinearRegression()
cv_scores = cross_val_score(cross_val_model, X_train, y_train, cv=5)
print(f"Cross-Validation R^2 Scores: {cv_scores}")
print(f"Mean Cross-Validation R^2: {np.mean(cv_scores)}")

# Decision Trees
dt_model = DecisionTreeRegressor()
dt_model.fit(X_train, y_train)
dt_predictions = dt_model.predict(X_train)
print(f"Decision Tree R^2: {r2_score(y_train, dt_predictions)}")

# Make predictions on test data
X_test = test_data.drop('id', axis=1)
X_test = sm.add_constant(X_test)
predictions = model.predict(X_test)
predictions_df = pd.DataFrame({'id': test_data['id'], 'FloodProbability': predictions})
predictions_df.to_csv('predictions.csv', index=False)