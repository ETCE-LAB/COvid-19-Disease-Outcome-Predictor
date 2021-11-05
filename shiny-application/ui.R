library(shiny)

# Define UI with input fields for all features of the model

ui <- function(req) {
  fluidPage(
  tags$link(rel="stylesheet", type="text/css", href="https://unpkg.com/tabulator-tables@4.9.3/dist/css/tabulator.min.css"),
  tags$link(rel="stylesheet", type="text/css", href="https://cdn.jsdelivr.net/gh/TUC-Circular-Economy-Department/COvid-19-Disease-Outcome-Predictor/shiny-application/www/ui.css"),
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
    ## HTML(" <p><b style='font-size: 16px; color:red'>3.</b> (You may skip this step if you do not have a .csv file with patient data). Download the following 'example table of patient data' (Note: the table is in .csv format, which can be opened with Excel):
    ## "),
    ## downloadLink("sampleFile", "Download the Example Table of patient data"),
    ## HTML(" </p>
##       <ul>
##         <li>Open the table and substitute the example values of the 12 features for the patient’s values you would like to add. Feel free to delete or add more rows depending on the number of patients that you would like CODOP to make the prediction on.</li>
##         <li><b>Important:</b> if the values of some features are missing for some patients, leave the corresponding cells empty or used a zero value.</li>
##         <li>Save the final table in .csv format in your computer.</li>
## <li>Upload the .csv file by clicking on 'Browse...' below, and the data should appear in an editable table.</li>
##       </ul>
##     "),
    HTML(" <p><b style='font-size: 16px; color:red'>3.</b> You may add new and edit existing patient data using the table below. Clicking on a cell allows you to edit the values. The 'Add Row' and 'Delete Last Row' buttons append an empty row and delete the last row, to and from the table respectively. </p>
    "),
    HTML("
      <p><b style='font-size: 16px; color:red'>4.</b> Click on 'PREDICT' to submit the patient data.</p>
    "),
    radioButtons("triageRadio", inline=TRUE,NULL,
                 choices = list("CODOP-Ovt" = 1, "CODOP-Unt" = 2), selected = 1),
    tags$div(id="patientData-Ovt",
                                        # Add the control buttons
             tags$div(
                      actionButton("add-patient-Ovt", "Add Row"),
                      actionButton("del-row-Ovt", "Delete Last Row"),
                      actionButton("compute-predictions-Ovt",
                                   "PREDICT",
                                   style = "background-color:#F03535;color:#FFFFFF;font-weight:bold;")),
             br(),
             tags$div(id="errorPane",

                      ),
             br(), tags$div(id="patientData-table-Ovt"),
             br()),
    HTML("<b style='font-size: 16px; color:red'>5.</b>"),
    span("If your patient table has missing values (including zeros), click the following box:"),

    checkboxInput("imputation", "Activate Imputation",FALSE),


    HTML("<b style='font-size: 16px; color:red'>6. </b>"),
    span("If all previous steps are performed correctly, you should see below a table that is similar to the one that you upload but with two extra columns with the predicted outcome. You can download this new table by pressing the “Download Predictions” tag. Thus, this table will be saved in the format selected in the dropdown menu."),
    hr(),
    tags$div(id="download-predictions-Ovt",
             actionButton("download-button", "Download Predictions"),
             selectInput("download-predictions-choice", NULL, 
                         choices = list("CSV" = "csv", "XLSX" = "xlsx",
                                        "PDF" = "pdf"), selected = 1)),
    

    ## actionButton("download-predictions-Ovt", "Download Predictions"),
    ## hr(),
                                        #HTML("<p>Prediction: 1=High probability of death  0=High probability of survival</p>"),

                                        # Table for the outputs to be displayed
    tags$div(id="tableOvt-output"),
    tableOutput("tableOvt"),



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

                                        # File Upload Tab ( second version)
    
    ),

  tags$script(src="https://cdn.jsdelivr.net/gh/TUC-Circular-Economy-Department/COvid-19-Disease-Outcome-Predictor/shiny-application/www/ui.js"),
  tags$script(src="https://cdn.jsdelivr.net/gh/TUC-Circular-Economy-Department/COvid-19-Disease-Outcome-Predictor/shiny-application/www/test.js"),

  tags$script(src="https://cdn.jsdelivr.net/npm/jquery.scrollto@2.1.3/jquery.scrollTo.min.js"),
  tags$script(src="https://cdn.jsdelivr.net/npm/jquery-csv@1.0.21/src/jquery.csv.min.js"),
  tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.4.0/jspdf.umd.min.js"),
  tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.20/jspdf.plugin.autotable.min.js"),
  tags$script(src="https://oss.sheetjs.com/sheetjs/xlsx.full.min.js"),
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
