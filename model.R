
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
  "edad"    = 6.004188e-03,
  "plaq"    = -2.472077e-07,
  "eosin"   = -9.174623e-06,
  "neutin"  = 7.551235e-06,
  "monin"   = -7.367404e-06,
  "pcrin"   = 7.458099e-04,
  "creain"  = 3.664203e-02,
  "ldh"     = 2.722994e-04,
  "soser"   = 5.894423e-03,
  "poser"   = 1.236685e-02,
  "glubas"  = 6.397398e-04,
  "dimerd"  = 3.290633e-07
  )

# ****
# imputation values
# ****
imputationValues <- c(
   "edad"   = 66.679109811566,
   "plaq"   = 250097.699563434,
   "eosin"  = 63.8181665997054,
   "neutin" = 5525.89391927775,
   "monin"  = 535.880366972477,
   "pcrin"  = 74.4896361594228,
   "creain" = 1.15657419376222,
   "ldh"    = 363.908290097421,
   "soser"  = 138.426808936312,
   "poser"  = 4.17844129554656,
   "glubas" = 124.285195339273,
   "dimerd" = 2122.15796236425
)


# ****
# Function for linear prediction model 
# ****
predict <- function(subject, activateImputation = FALSE) {
  propability <- 0
  # add intercept to subject(value=1)
  subject <- setNames(c(subject, 1), c(names(subject), "intercept"))
  
  # Multiplicate subject data with coefficients
  n <- length(names(coefficients))
  for( i in 1:n) {
    name <- names(coefficients)[i]
    # Cast subject value to numeric
    subjectValue <- convertToNumeric(subject[name])
    # Numeric values: just compute
    if ( (! is.na(subjectValue)) && is.numeric(subjectValue) ) {
      propability <- propability + coefficients[name] * subjectValue
    # Non-Numeric value with imputation 
    } else if (activateImputation) {
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
