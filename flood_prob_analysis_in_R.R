library(tidyverse)
library(tree)
library(caret)
library(polycor)

set.seed(5)

#read the datasets in R
train_data <- read_csv("train.csv", show_col_types = FALSE)  
train_y <- train_data$FloodProbability
va_inds <- sample(nrow(train_data), .3*nrow(train_data))
train_data <- train_data[-va_inds,]
valid_data <- train_data[va_inds,]

test_data <- read_csv("test.csv", show_col_types = FALSE)

print(colnames(train_data))


# Creating a linear model
Model0 <- lm(FloodProbability ~ . , data=train_data)
summary(Model0) # Multiple R-squared:  0.845,     Adjusted R-squared:  0.8449  # original -> 0.84458

cor_matrix <- cor(train_data)
target_correlations <- cor_matrix["FloodProbability", -ncol(cor_matrix)]

print(target_correlations)
summary(train_data)
# predicting for test_data
predictions_model0 <- predict(Model0,test_data)


submission_data_model0 <- 
    data.frame(id = test_data$id, FloodProbability = predictions_model0)

write.table(submission_data_model0, 
            "submission_model0.csv", row.names = FALSE, sep = ",")


# finding outliers and processing on data
# finding the row number with max value
which.max(train_data$MonsoonIntensity)
#finding the full row data that contains max value
train_data[which.max(train_data$MonsoonIntensity),]


# creating a function to remove the max values (that I am thinking as outliers)
removing_max_values <- function(df){
for(i in colnames(df)){
    # print(i)
    # to remove only one row of max value
    # max_value_index <- which.max(df[[i]])  # In R, you can’t use the $ operator with a variable directly. You need to use the [[ ]] operator instead.
    # df <- df[-max_value_index, ]
    
    # to remove all rows of max values
    if( (i != 'id') && (i != 'FloodProbability') && (i != 'TopographyDrainage')&&(i != 'DamsQuality') &&(i != ' DeterioratingInfrastructure')){
        print(i)
        max_value <- max(df[[i]], na.rm = TRUE)
        df <- df[df[[i]] != max_value, ]
    }
}
return(df)
}

train_data$my_col <- train_data$TopographyDrainage* train_data$DeterioratingInfrastructure

dim(train_data)
summary(train_data)

train_data <- removing_max_values(train_data)

dim(train_data)
summary(train_data)

# Retrying a linear model
Model2 <- lm(FloodProbability ~ . , data=train_data)
summary(Model2)
summary(Model2)$r.squared


# predicting for test_data
predictions_valid <- predict(Model2,valid_data)

# predicting for test_data
predictions_model2 <- predict(Model2,test_data)


submission_data_model2 <- 
    data.frame(id = test_data$id, FloodProbability = predictions_model2)

write.table(submission_data_model2, 
            "submission_model3.csv", row.names = FALSE, sep = ",")


# Polynomial regression
poly_features <- poly(train_data[, -which(names(train_data) == "FloodProbability")], degree = 2, raw = TRUE)
poly_model <- lm(FloodProbability ~ poly_features, data=train_data)
summary(poly_model)

# Predicting for test_data using polynomial regression
poly_test_features <- poly(test_data, degree = 2, raw = TRUE)
poly_predictions <- predict(poly_model, poly_test_features)


# CROSS VALIDATION
# Specify cross-validation method (k = 5)
ctrl <- trainControl(method = "cv", number = 5)

# Fit a linear regression model and evaluate performance
Cross_model <- train(FloodProbability ~ . -id, data = train_data, method = "lm", trControl = ctrl)


summary(Cross_model)

# predicting for test_data
predictions_model3 <- predict(Cross_model,test_data)


submission_data_model3 <- 
    data.frame(id = test_data$id, FloodProbability = predictions_model3)

write.table(submission_data_model3, 
            "submission_model4.csv", row.names = FALSE, sep = ",")


# DECISION TREES

# Load the rpart package
library(rpart)



# Fit a regression tree
DT_model <- rpart(FloodProbability ~ ., data = train_data, method = "anova")
summary(DT_model)$r.squared

# Make predictions (use your test data)
predictions_model4 <- predict(DT_model, newdata = valid_data)

# Calculate R² score
library(caret)
r2_score <- R2(predicted_values, valid_data$FloodProbability)
print(paste("R² Score:", round(r2_score, 4)))

submission_data_model4 <- 
    data.frame(id = test_data$id, FloodProbability = predictions_model4)

write.table(submission_data_model3, 
            "submission_model4.csv", row.names = FALSE, sep = ",")
