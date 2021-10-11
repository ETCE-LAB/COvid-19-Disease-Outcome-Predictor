library(shiny)

# Define UI with input fields for all features of the model

ui <- function(req) {
  fluidPage(
  tags$link(rel="stylesheet", type="text/css", href="https://unpkg.com/tabulator-tables@4.9.3/dist/css/tabulator.min.css"),
  tags$script(src="https://unpkg.com/tabulator-tables@4.9.3/dist/js/tabulator.min.js"),
  tags$script(src="https://cdn.jsdelivr.net/npm/json2csv@4.2.1"),
  shinyjs::useShinyjs(),
  title = "COVID-19 Calculator",
  br(),

  # Checkbox for terms of use and warning message
  h2("Instructions of use"),
  HTML("<p><b style='font-size: 16px; color:red'>1.</b> Click on the following box for accepting the Terms and Conditions of the CODOP Calculator:</p>"
  ),
  checkboxInput("terms",
                HTML("I agree to the <a href='https://gomezvarelalab.em.mpg.de/covid-calculator-terms-of-use/' target='_blank'>
                      terms and conditions</a> of the COVID calculator"),
                FALSE),
  span(textOutput("warning"), style="color:red"),


  # Tabs
  div(
    id = "tabs",
    HTML("<p><b style='font-size: 16px; color:red'>2.</b> Select between CODOP-Unt and CODOP-Ovt (see explanation of the characteristics of these two predictor subtypes above).</p>"),
    HTML(" <p><b style='font-size: 16px; color:red'>3.</b> (You may skip this step if you do not have a .csv file with patient data). Download the following 'example table of patient data' (Note: the table is in .csv format, which can be opened with Excel):
    "),
    downloadLink("sampleFile", "Download the Example Table of patient data"),
    HTML(" </p>
      <ul>
        <li>Open the table and substitute the example values of the 12 features for the patient’s values you would like to add. Feel free to delete or add more rows depending on the number of patients that you would like CODOP to make the prediction on.</li>
        <li><b>Important:</b> if the values of some features are missing for some patients, leave the corresponding cells empty or used a zero value.</li>
        <li>Save the final table in .csv format in your computer.</li>
<li>Upload the .csv file by clicking on 'Browse...' below, and the data should appear in an editable table.</li>
      </ul>
    "),
HTML("
      <p><b style='font-size: 16px; color:red'>4.</b> You may add new and edit existing patient data using the 'Add', 'Undo', 'Redo', 'Delete' buttons below. The 'Add' and 'Delete' buttons append an empty row and delete the last row, in the table respectively. </p>
    "),
HTML("
      <p><b style='font-size: 16px; color:red'>5.</b> Click on 'Predict' to submit the patient data.</p>
    "),
tabsetPanel(type = "tabs",



                                        # Online Form Tab
                                        # tabPanel("Online Form (1 Patient)",
                                        #
                                        #          br(),
                                        #          fluidRow(
                                        #            column(3,numericInput("edad", h5("Age(years)"),value = 66.6791)),
                                        #            column(3,numericInput("ldh", h5("Lactate Dehydrogenase(U/L)"), value = 363.9082)),
                                        #            column(3, numericInput("dimerd", h5("D-Dimer(ng/mL)"), value = 2122.1579))
                                        #          ),
                                        #          fluidRow(
                                        #            column(3,numericInput("glubas",h5("Glucose(mg/dL)"), value = 124.2851)),
                                        #            column(3,numericInput("poser", h5("Serum Potassium(mmol/L)"), value = 4.1784)),
                                        #            column(3,numericInput("soser", h5("Serum Sodium(mmol/L)"), value = 138.4268))
                                        #          ),
                                        #          fluidRow(
                                        #            column(3,numericInput("pcrin", h5("C-Reactive Protein(mg/L)"),value = 74.4896)),
                                        #            column(3,numericInput("creain", h5("Creatinine(mg/dL)"), value = 1.1565)),
                                        #            column(3,numericInput("eosin", h5("Eosinophils(x10^6/L)"),value = 63.8181))
                                        #          ),
                                        #          fluidRow(
                                        #            column(3,numericInput("monin", h5("Monocytes(x10^6/L)"), value = 535.8803)),
                                        #            column(3,numericInput("neutin", h5("Neutrophils(x10^6/L)"),value = 5525.8939)),
                                        #            column(3,numericInput("plaq", h5("Platelet Count(mg/dL)"),value = 250097.6995))
                                        #          ),
                                        #          br(),
                                        #          h4(textOutput("prop"))
                                        # ),

                                        # File Upload Tab ( default version)
            tabPanel("CODOP-Ovt",
                     br(),

                     ## fileInput("patientFile", "", #"Upload a CSV file with patient data",
                     ##          multiple = FALSE,
                     ##          accept = c("text/csv",
                     ##                     "text/comma-separated-values,text/plain",
                     ##                     ".csv")),
                                        #downloadLink("sampleFile", "Download the Example Table of patient data"),
                                        # Add the div for the editable table and controls
                     tags$div(id="patientData-Ovt",
                                        # Add the control buttons
                              tags$div(
                                       actionButton("add-patient-Ovt", "Add"),
                                       actionButton("undo-edit-Ovt", "Undo"),
                                       actionButton("redo-edit-Ovt", "Redo"),
                                       actionButton("del-row-Ovt", "Delete"),
                                       actionButton("compute-predictions-Ovt", "Predict")),
                              br(), tags$div(id="patientData-table-Ovt"),
                              br(),
                                        # File input for loading csv to the table
                              tags$input(type="file", placeholder="No patient data file uploaded",  id="upload-csv-Ovt", accept="text/csv")),
                     br(),
                     
                                        # Checkbox for imputation
                     HTML("<b style='font-size: 16px; color:red'>6.</b>"),
                     span("If your patient table has missing values, click the following box:"),

                     checkboxInput("imputation", "Activate Imputation",FALSE),


                     HTML("<b style='font-size: 16px; color:red'>7. </b>"),
                     span("If all previous steps are performed correctly, you should see below a table that is similar to the one that you upload but with two extra columns with the predicted outcome.
                        You can download this new table by pressing the “Download Predictions” tag. Thus, this table will be saved in .csv format in your computer.
                  "),
                  hr(),
                  actionButton("download-predictions-Ovt", "Download Predictions"),
                  hr(),
                                        #HTML("<p>Prediction: 1=High probability of death  0=High probability of survival</p>"),

                                        # Table for the outputs to be displayed
                  tableOutput("tableOvt"),
                  ),

                                        # File Upload Tab ( second version)
            tabPanel("CODOP-Unt",
                     br(),
                                        # Add the div for the editable table and controls
                     tags$div(id="patientData-Unt",
                              tags$div(
                                        # Add the controls
                                       actionButton("add-patient-Unt", "Add"),
                                       actionButton("undo-edit-Unt", "Undo"),
                                       actionButton("redo-edit-Unt", "Redo"),
                                       actionButton("del-row-Unt", "Delete"),
                                       actionButton("compute-predictions-Unt", "Predict")),
                              br(),
                                        # File input for loading csv to the table
                              tags$div(id="patientData-table-Unt"),
                              br(),
                              tags$input(type="file",
                                         placeholder="No patient data file uploaded",
                                         id="upload-csv-Unt",
                                         accept="text/csv")),
                     
                     ## fileInput("patientFileUnt", "", #"Upload a CSV file with patient data",
                     ##            multiple = FALSE,
                     ##            accept = c("text/csv",
                     ##                       "text/comma-separated-values,text/plain",
                     ##                       ".csv")),
                                        #downloadLink("sampleFileUnt", "Download sample file"),
                     br(),

                                        # Checkbox for imputation
                     HTML("<b style='font-size: 16px; color:red'>4.</b>"),
                     span("If your patient table has missing values, click the following box:"),

                     checkboxInput("imputationUnt", "Activate Imputation",FALSE),

                     HTML("<b style='font-size: 16px; color:red'>5. </b>"),
                     span("If all previous steps are performed correctly, you should see below a table that is similar to the one that you upload but with two extra columns with the predicted outcome.
                               You can download this new table by pressing the “Download Predictions” tag. Thus, this table will be saved in .csv format in your computer.
                         "),
                     hr(),
                     actionButton("download-predictions-Unt", "Download Predictions"),
                     hr(),
                                        #HTML("<p>Prediction: 1=High probability of death  0=High probability of survival</p>"),
                                        # Table for the outputs to be displayed
                     tableOutput("tableUnt"),
                     )
            )
),

tags$script(src="ui.js"),
tags$script(src="https://cdn.jsdelivr.net/npm/jquery-csv@1.0.21/src/jquery.csv.min.js"),
                                        # Invisible Textfield that contains the IP address (is used later on to store the clients IP)
div(style = "display: none;",
    textInput("remote_addr", "remote_addr",
              if (!is.null(req[["HTTP_X_FORWARDED_FOR"]]))
                  req[["HTTP_X_FORWARDED_FOR"]]
              else
                  req[["REMOTE_ADDR"]]
              )
    )
)}
