rm(list=ls(all=T))

setwd("SET YOUR WORKING DIRECTORY")

train <- read.csv("train.csv", header = TRUE, sep = ",")
test <- read.csv("test.csv", header = TRUE, sep = ",")

train$SignWidth <- NULL
train$SignHeight <- NULL
train$Id <- NULL

test$SignWidth <- NULL
test$SignHeight <- NULL
testid <- test$Id
test$Id <- NULL

colnames(train)[4] <- "Target"

## REMOVE TARGET VARIABLE FROM DATAFRAME BEFORE PASSING TO XGBOOST
trainxgb <- subset(train, select = -Target)

## CONVERT THE TARGET CLASSES TO NUMERIC AS XGBOOST WORKS ONLY WITH NUMERIC VALUES
xgbtarget <- as.numeric(train$Target)-1
require(xgboost)

xgb <- xgboost(data = data.matrix(trainxgb), 
                label = xgbtarget, 
                booster = "gbtree",
                nrounds = 1000,
                eta=0.1,
                gamma=0.7,
                #max_depth=2,
                min_child_weight=5,
                subsample=0.5,
                colsample_bytree=1,
                eval_metric = "mlogloss",
                objective = "multi:softprob",
                verbose = 1,
                print_every_n = 50,
                early_stop_round=3,
                maximize = F,
                num_class = 4,
                nthread = 3)


pred <- predict(xgb, data.matrix(test))

## OBJECTIVE MULTI:SOFTPROB GIVES PROBABILITIES AS NUM_CLASS * NUM_DATAPOINTS, SO WE NEED TO RESHAPE THE DATAFRAME
pred1 <- data.frame(t(matrix(pred, nrow = 4, ncol = length(pred)/4)))
final_pred <-cbind(testid,pred1)

names(final_pred) <- c("Id","Front","Left","Rear","Right")
write.csv(final_pred,"final_prediction_XGB.csv", row.names = FALSE)

