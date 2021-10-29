library(shiny)
# options(shiny.fullstacktrace = TRUE)
library(RMySQL)

source("model.R")
source("database.R")

# Mock data model
# require(glmnet)
# load("sample_model.RData") # Path to load the sample model 

# ****
# Server logic, that takes the form input and calls the prediction model
# ****
shinyServer(function(input, output, session) {
  
  # ****
  # Calculation and input conversion for online form
  # Calculate risk with form data and display it in a textfield
  # ****
  # output$prop <- renderText({
  #   subject <- c( 
  #     "edad" = as.numeric(input$edad),
  #     "plaq" = as.numeric(input$plaq),
  #     "eosin"  = as.numeric(input$eosin),
  #     "neutin"  = as.numeric(input$neutin),
  #     "monin"    = as.numeric(input$monin),
  #     "pcrin"  = as.numeric(input$pcrin),
  #     "creain" = as.numeric(input$creain),
  #     "ldh" = as.numeric(input$ldh),
  #     "soser"  = as.numeric(input$soser),
  #     "poser"  = as.numeric(input$poser),
  #     "glubas" = as.numeric(input$glubas),
  #     "dimerd" = as.numeric(input$dimerd)
  #   )
  #   prop <- predict(subject)
  #   binaryInformation <- ""
  #   if( prop < threshold) {
  #     binaryInformation <- "0=High probability of survival."
  #   } else {
  #     binaryInformation <- "1=High probability of death."
  #   }
  #   paste( "Prediction: ", binaryInformation
  #          #, "Score of severe disease progression:", round(prop, digits = 4)
  #          )
  # })
  
  # ***
  # Isolate client's IP
  # ***
  ip <- isolate(input$remote_addr)
  
  # Hide tabs and download button in the beginning
  shinyjs::hide("tabs")
  #shinyjs::hide("tableOvt")
  
  # ****
  # Reactive function to check if terms are accepted 
  # ****

    output$warning <- renderText({ 
    if(!input$terms){
      paste("Please accept the terms and coditions to proceed")
    } else {
      shinyjs::disable("terms")
      shinyjs::show("tabs")
      saveUserData(ip, 1)
      paste("")
    }
  })
   
  # ****
  # Reactive function that displays the table and shows the download button
  # ****
  
  output$tableOvt <- renderTable({
  #Check if terms are accepted
   shinyjs::hide("download-predictions-Ovt")

   if(input$terms){
    
     # Check if patientDataCSV_Ovt is set (Currently does not work as intended. Some debugging required)

       req(input$patientDataCSV_Ovt)

       threshold<- NULL
       if (input$triageRadio == 1){
           threshold<-thresholdOvt
       }
       else if (input$triageRadio == 2){
           threshold<-thresholdUnt
       }
       else{
           showNotification("Could not choose correct model (CODOP-Ovt/CODOP-Unt)", type="error")
       }
                                        # Get predictions
       df <- readRawCSVAndAddRisks(input$patientDataCSV_Ovt, input$imputation, threshold)
       shinyjs::show("download-predictions-Ovt")
       
                                        # Check for missing values
       if(NA %in% unlist(df["Prediction"], use.names=FALSE)){
         showNotification("Could not calculate score Please check if all required columns exist and are spelled correctly", type="error")
     }
       saveUserData(ip, nrow(df))
       session$sendCustomMessage("CODOP-Predictions", df)
       return(df)
   }
  },
  digits = 8)
  
  ## output$tableUnt <- renderTable({
  ## #Check if terms are accepted
  ##  shinyjs::hide("download-predictions-Unt")
  ##  if(input$terms) {
    
  ##    # Check if a file was uploaded
       
  ##    # Check if patientDataCSV_Unt is set (Currently does not work as intended. Some debugging required)

  ##    req(input$patientDataCSV_Unt)

  ##    df <- readRawCSVAndAddRisks(input$patientDataCSV_Unt, input$imputationUnt, thresholdUnt)
  ##      shinyjs::show("download-predictions-Unt")

  ##     # Check for missing values
  ##    if(NA %in% unlist(df["Prediction"], use.names=FALSE)){
  ##      showNotification("Could not calculate score Please check if all required columns exist and are spelled correctly", type="error")
  ##    }
  ##    saveUserData(ip, nrow(df))
  ##    return(df)
  ##    }
  ##  },
  ## digits = 8)
  
  # ****
  # Reactive function for the result download button 
  # ****
  ## output$downloadOvt <- downloadHandler(
  ##  filename = "Covid_calculated_scores.csv",
  ##  content = function(file) {
  ##    write.csv(readCSVAndAddRisks(input$patientFile$datapath, input$imputation, thresholdOvt), file, row.names = FALSE)
  ##  }
  ## )
  ## output$downloadUnt <- downloadHandler(
  ##  filename = "Covid_calculated_scores.csv",
  ##  content = function(file) {
  ##    write.csv(readCSVAndAddRisks(input$patientFileUnt$datapath, input$imputationUnt, thresholdUnt), file, row.names = FALSE)
  ##  }
  ## )
  
  # ****
  # Reactive function for the sample file download button 
  # ****
  output$sampleFile <- downloadHandler(
   filename = "sample_patients.csv",
   content = function(file) {
     write.csv(
       read.csv("patients_example.csv",
                        header = TRUE,
                        check.names=FALSE), file, row.names = FALSE)
   }
  )
  output$sampleFileUnt <- downloadHandler(
   filename = "sample_patients.csv",
   content = function(file) {
     write.csv(
       read.csv("patients_example.csv",
                        header = TRUE,
                        check.names=FALSE), file, row.names = FALSE)
   }
  )
})
# --- END SERVER

# ****
# Function to read CSV and calculate risks
# Returns dataframe with patient data and risks
# ****


readCSVAndAddRisks <- function(filePath, activateImputation, threshold) {
  tryCatch(
    {
      df <- read.csv(filePath,
                     header = TRUE,
                     check.names=FALSE)
      props = NULL
      predictions = NULL
      binPredictions = NULL
      for (i in 1:nrow(df)) {
        row = unlist(df[i, ])
        newPrediction = predict(row, activateImputation)
        if ( is.na(newPrediction)){
          stop("Empty cells are detected. Please click the “Activate Imputation” box")
        } 
        props = c(props,  newPrediction)
        predictions = c(predictions,  if(newPrediction < threshold)  "High Probability of Survival" else "High Probability of Death")
        binPredictions = c(binPredictions,  if(newPrediction < threshold)  "0" else "1")
      }
      # Add score as the first row
      #df["Prediction Value"] = props
      df["Prediction"] = predictions
      df["Binary Prediction"] = binPredictions
      
      df <- df[,c(which(colnames(df)=="Binary Prediction"),
                  which(colnames(df)!="Binary Prediction"))]
      #df <- df[,c(which(colnames(df)=="Prediction Value"),
      #            which(colnames(df)!="Prediction Value"))]
      df <- df[,c(which(colnames(df)=="Prediction"),
                  which(colnames(df)!="Prediction"))]
      return(df)
    }
    ,
    error = function(e) {
      # return a safeError if a parsing error occurs
      stop(safeError(e))
    }
  )
  return(NA)
}

# ****
# Function to read JSON and calculate risks
# Returns dataframe with patient data and risks
# Replica of the previous function to support editable tables
# ****
 
readRawCSVAndAddRisks <- function(rawCSV, activateImputation, threshold) {
  tryCatch(
    {
      df <- read.csv(text=rawCSV, sep="|", header=TRUE, check.names=FALSE)

      ## df <- read.csv(filePath,
      ##                header = TRUE,
      ##                check.names=FALSE)

      props = NULL
      predictions = NULL
      binPredictions = NULL
      for (i in 1:nrow(df)) {
        row = unlist(df[i, ])
        newPrediction = predict(row, activateImputation)
        if ( is.na(newPrediction)){
          stop("Empty cells are detected. Please click the “Activate Imputation” box")
        } 
        props = c(props,  newPrediction)
        predictions = c(predictions,  if(newPrediction < threshold)  "High Probability of Survival" else "High Probability of Death")
        binPredictions = c(binPredictions,  if(newPrediction < threshold)  "0" else "1")
      }
      # Add score as the first row
      #df["Prediction Value"] = props
      df["Prediction"] = predictions
      df["Binary Prediction"] = binPredictions
      
      df <- df[,c(which(colnames(df)=="Binary Prediction"),
                  which(colnames(df)!="Binary Prediction"))]
      #df <- df[,c(which(colnames(df)=="Prediction Value"),
      #            which(colnames(df)!="Prediction Value"))]
      df <- df[,c(which(colnames(df)=="Prediction"),
                  which(colnames(df)!="Prediction"))]
      return(df)
    }
    ,
    error = function(e) {
      # return a safeError if a parsing error occurs
      stop(safeError(e))
    }
  )
  return(NA)
}

# ****
# Function to save data into the database
# ****
saveUserData <- function(ip, patients) {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (IP,patients) VALUES ('%s', '%s')",
    table, 
    paste(ip),
    paste(patients)
  )
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

# ****
# Returns a new dataframe with all non-numeric values replaced by "-", 
# so that they are more noticeable for the user
# !! ATTENTION: DO ONLY CAll THIS FOR DISPLAYING THE TABLE. 
#               THE PREDICTION FUNCTION WONT WORK ON THE OUTCOME OF THIS FUNCTION (dont ask me why)
#               (SOMEWHERE THERE MUST BE SOME CALL BY REFERENCE PROBLEMS, WHICH DEleTES COL NAMES)
# ****
# replaceNonNumericValues <- function(df) {
#   copiedDf <- data.frame(df)
#   for(j in 1:nrow(copiedDf))
#   {
#     for(k in 1:ncol(copiedDf))
#     {
#       # Try casting value to numeric
#       subjectValue <- convertToNumeric(copiedDf[j,k])
#       
#       # Replace value if NaN or non-numeric
#       if ( is.na(subjectValue) || (!is.numeric(subjectValue)) ) {
#         copiedDf[j,k] <- "-"
#       }
#     }
#   }
#   return(copiedDf)
#}
