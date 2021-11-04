
                                        # ********************
                                        # This file contains all information for the prediction model
                                        # ********************

                                        # ****
                                        # Threshold for deciding if patient will survive 
                                        # ****
thresholdOvt <- 0.16770
thresholdUnt <- 0.3901752

                                        # ****
                                        # Current coefficients
                                        # ****
coefficients <- c(
    "intercept" =  -1.330923,
    "Age"    = 6.004188e-03,
    "Platelets (x10^6/L)"    = -2.472077e-07,
    "Eosinophils (x10^6/L)"   = -9.174623e-06,
    "Neutrophils  (x10^6/L)"  = 7.551235e-06,
    "Monocytes  (x10^6/L)"   = -7.367404e-06,
    "C-Reactive Protein (mg/L)"   = 7.458099e-04,
    "Creatinine (mg/dL)"  = 3.664203e-02,
    "Lactate Dehydrogenase (U/L)"     = 2.722994e-04,
    "Sodium (Natremia; mmol/L)"   = 5.894423e-03,
    "Potassium (Kalemia; mmol/L)"   = 1.236685e-02,
    "Glucose (mg/dL)"  = 6.397398e-04,
    "D-dimer (ng/mL)"  = 3.290633e-07
)

                                        # ****
                                        # imputation values
                                        # ****

imputationValues <- c(
    "Age" = 66.679109811566,
    "Platelets (x10^6/L)" = 250097.699563434,
    "Eosinophils (x10^6/L)" = 63.8181665997054,
    "Neutrophils  (x10^6/L)" = 5525.89391927775,
    "Monocytes  (x10^6/L)" = 535.880366972477,
    "C-Reactive Protein (mg/L)" = 74.4896361594228,
    "Creatinine (mg/dL)" = 1.15657419376222,
    "Lactate Dehydrogenase (U/L)" = 363.908290097421,
    "Sodium (Natremia; mmol/L)" = 138.426808936312,
    "Potassium (Kalemia; mmol/L)" = 4.17844129554656,
    "Glucose (mg/dL)" = 124.285195339273,
    "D-dimer (ng/mL)" = 2122.15796236425
)

## "edad"
## "plaq"
## "eosin"
## "neutin"
## "monin"
## "pcrin"
## "creain"
## "ldh"
## "soser"
## "poser"
## "glubas"
## "dimerd"

## SpO2, Hb, Plaquetas, linfocitos, neutrófilos, LDH,
## GOT, GPT, Sodio, Potasio, Glucosa, tiempo de protrombina,
## fibrinógeno y dímero D, creatinine



imputationCategory1 <- list("Platelets (x10^6/L)",
                            "Neutrophils  (x10^6/L)",
                            "Lactate Dehydrogenase (U/L)",
                            "Sodium (Natremia; mmol/L)",
                            "Potassium (Kalemia; mmol/L)",
                            "Glucose (mg/dL)",
                            "D-dimer (ng/mL)",
                            "Creatinine (mg/dL)")

## Eosinofiles, monocytes, prcin and bilirubin

imputationCategory2 <- list("Eosinophils (x10^6/L)",
                            "Monocytes  (x10^6/L)",
                            "C-Reactive Protein (mg/L)")


                                        # ****
                                        # Function for linear prediction model 
                                        # ****
predict <- function(subject, activateImputation = FALSE) {
    propability <- 0
                                        # add intercept to subject(value=1)
    subject <- setNames(c(subject, 1), c(names(subject), "intercept"))
    
                                        # Multiplicate subject data with coefficients
    n <- length(names(coefficients))
    print("---------------------------------\n")
    for( i in 1:n) {
        name <- names(coefficients)[i]
                                        # Cast subject value to numeric
        subjectValue <- convertToNumeric(subject[name])
                                        # Numeric values: just compute
        if ( (! (subjectValue == 0 && name %in% imputationCategory1)) && 
             (! is.na(subjectValue)) && is.numeric(subjectValue) ) {
            propability <- propability + coefficients[name] * subjectValue
                                        # Non-Numeric value with imputation 
        } else if (activateImputation) {
            print(paste("Imputing",
                        name,
                        ":",
                        toString(subjectValue),
                        "->",
                        toString(imputationValues[name])))
            propability <- propability + coefficients[name] * imputationValues[name]
                                        # Non-Numeric value but imputation is deactivated
        } else {
            return(NaN)
        }
    }
    names(propability) <- NULL
    return(propability)
}

                                        # ****
                                        # Converts this annoying type whatsoever thing that appears all the time to numeric
                                        # ****
convertToNumeric <- function(value){
    outputValue <- as.numeric(value)
                                        #names(outputValue) <- NULL
                                        #outputValue <- as.numeric(outputValue)
    return(outputValue)
}
