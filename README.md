# COvid-19 Disease Outcome Predictor (CODOP)

- [Server Setup](#server-setup)
  - [Setup Shiny Server](#setup-shiny-server)
  - [Setup Apache and MySQL Server](#setup-apache-and-mysql-server)
- [Application Setup](#application-setup)
  - [Import/Update the Shiny Application](#importupdate-the-shiny-application)
- [Documentation](#documentation)
  - [ui.R](#uir)
  - [www/ui.js](#wwwuijs)
	- [Table Editing](#table-editing)
	- [Error Messages](#error-messages)
	- [Shiny Server Communication](#shiny-server-communication)
  - [www/test.js](#wwwtestjs)
  - [server.R](#serverr)
  - [model.R](#modelr)
- [Debugging](#debugging)
  - [Testing Predictions](#testing-predictions)
  
## Server Setup 

This section explains how to setup all components of the server on Ubuntu server 16.04.

### Setup Shiny Server
This section explains how to install the Shiny Server. If you already have a running Shiny server and just want to setup or update the COVID application go to [ Import/Update the Shiny Application](#Import/Update-the-Shiny-Application)

Install R (Please replace xenial-cran40 with your correspondent ubuntu version) 
```
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/'
gpg --keyserver keyserver.ubuntu.com --recv-key 51716619E084DAB9
gpg -a --export 51716619E084DAB9 | sudo apt-key add -
sudo apt update
sudo apt-get install r-base r-base-dev
```
**Attention:** xenial might need to be replaced by your server's version. Check it by running `sudo lsb_release -a`.
**Attention:** If the second line runs into an error, try running `gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 51716619E084DAB9` instead

Install necessary packages and download deb file for shiny server 
```
sudo apt-get install gdebi-core
sudo su - \ -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
```

Install required R packages
```
sudo R
install.packages("glmnet", dependencies=TRUE)
install.packages("shiny")
install.packages("shinyjs")
install.packages("RMySQL")
q()
```
(If this installation runs into problems you may have an older version of R and need to upgrade. For this follow the first step of this section and replace the deb by a correct an new one.  
After upgrading R, you might need to run `update.packages(checkBuilt = TRUE, ask = FALSE)` in R in order to upgrade all R packages)

Run shiny server 
```
sudo gdebi shiny-server-1.5.14.948-amd64.deb
```

Copy shiny application to a subdirectory of `/srv/shiny-server/`, e.g. `/srv/shiny-server/myApp`.  
The application can then be accessed on `<your-ip-address>:3838/myApp`.  
**Important:** Accessing port 3838 need to be allowed by the security guidelines of your server

You can check your Shiny server by accessing `<your-ip-address>:3838/sample-apps/hello/`

You can stop and start the shiny server from now on by running 
```
sudo systemctl stop shiny-server.service
sudo systemctl start shiny-server.service  
```

### Setup Apache and MySQL Server 
This section explains how to install and configure a server using apache and mysql. If you already have a preconfigred wordpress server you can skip this section.


Install php, apache and mysql
```
sudo apt update
sudo apt install php libapache2-mod-php mysql-server php-mysql
sudo apt-get install libmysqlclient-dev
```

We need to store the apache logs of the last 7 days. For this, open the file `/etc/logrotate.d/apache2` and change the line `rotate 14` to `rotate 7`.

To create a crontab that copies the covid-calculator usage statistics to log files, run `sudo crontab -e` and append the following line
```
00 2 * * * mkdir /GomezWebLogs/"covid-calculator-logs-"` date -d "-1day" +"\%d-\%m-\%Y"` ; mysql -u root -e 'select * from covid_calculator_users where DATE(date) = subdate(current_date, 1) order  by date;' lab_wordpress > /GomezWebLogs/"covid-calculator-logs-"` date -d "-1day" +"\%d-\%m-\%Y"`/"covid-calculator-logs-"` date -d "-1day" +"\%d-\%m-\%Y"`;
```
The crontab runs every night at 02:00 server time (04:00) and creates a folder at `/GomezWebLogs` that contains a logfile of the covid-calculator usage

Configure the database 
```
sudo mysql_secure_installation
sudo mysql -u root
```
 
Run the following commands inside the mysql command line to create the database and a new user
```
CREATE DATABASE lab_wordpress;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON lab_wordpress.* TO wordpress_user@localhost IDENTIFIED BY '<your-password>';
FLUSH PRIVILEGES;

```

Additionally create a table for the shiny application:
```
CREATE TABLE lab_wordpress.`covid_calculator_users` (
	`patients` INT(10) UNSIGNED ZEROFILL NOT NULL,
	`IP` VARCHAR(20) NOT NULL,
	`date` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`IP`, `date`)
)
ENGINE=InnoDB;
```

Quit mysql
```
quit
```

Enable mysql
```
sudo service mysql start
```

## Application Setup
This section explains how to setup and update the applications. Please make sure to first [setup the server](#Server-Setup)

### Import/Update the Shiny Application

In order to import the Shiny COVID application, just copy the content of `./shiny-application` to `/srv/shiny-server/covid`. You can alternatively copy it to `/srv/shiny-server/` and delete all other files from the directory, if you want the app to run on `localhost:3838` instead of `localhost:3838/covid`.  
(To update the prediction model you just need to replace `model.RData`)
```
sudo mkdir /srv/shiny-server/covid
sudo cp ./shiny-application/* /srv/shiny-server/covid
```

You may need to update the hyperlink to the terms of use. You can change the hyperlink inside `/srv/shiny-server/covid/ui.R`.

Make a copy of `database-example.R` and change its values to match your database connection
```
sudo cp /srv/shiny-server/covid/database-example.R /srv/shiny-server/covid/database.R
```

Restart the Shiny server
```
sudo systemctl stop shiny-server.service
sudo systemctl start shiny-server.service
```

You can now open the shiny application `<your-ip-address>:3838/covid`

## Documentation

This section documents the functionality of the shiny app in the
`shiny-application` sub-directory.

### ui.R

This `ui.R` file defines the shiny-application's user interface.

### www/ui.js

The `ui.js` file implements functions and event listeners required for
the browser user interface.


The following javascript libraries are included into the user interface via
cdns:

1. [Tabulator](https://github.com/olifolkerd/tabulator): Editing and
   displaying patient data and predictions respectively.
2. [json2csv](https://github.com/zeMirco/json2csv): json to csv conversion.
3. [jquery-csv](https://github.com/evanplaice/jquery-csv): csv to json conversion
4. [jquery.scrollTo](https://github.com/flesler/jquery.scrollTo):
   programmatic scrolling
5. [jspdf](https://github.com/parallax/jsPDF): pdf generation
   compatibility extension for Tabulator
6. [jspdf-autotable](https://github.com/simonbengtsson/jsPDF-AutoTable):
   Table extension for jspdf
7. [sheetjs](https://github.com/SheetJS/sheetjs): xlsx generation
   compatibility extension for Tabulator

### www/test.js

See [Testing Predictions](#testing-predictions) below.
	
#### Table Editing

Tabulator's default editing features are used for editing cells, and
adding/deleting rows. Tabulator Mutators are written to make sure all
values are numeric.

#### Error Messages

Error messages are implemented using the validation features of
Tabulator. Since Tabulator does not implement error messages, but does
support callbacks on cell edit events, a mixture of automatic and
manual validation is used. See [Tabulator 4.9 Documentation](http://www.tabulator.info/docs/4.9/validate#manual). 

Dynamic error labels are added above the table that are scrolled to
automatically. Clicking on error messages will autoscroll to the
culprit cell. All error autoscrolling only occurs if the target is
outside the current viewport.

When the **PREDICT** button Error messages are either redisplayed or
removed if the table is invalid or valid repsectively.


#### Shiny Server Communication

Since Shiny does not like GET/POST requests, the json patient data is
converted to a csv string first and is 'sent' by setting an input when
the 'Predict' button is clicked.

The Shiny server uses the model and returns a dataframe with the
predictions. The dataframe is sent to the browser by setting an
output, which is detected using event listeners.

<!-- , which is rendered by the Shiny client on the browser
page --> <!-- as a HTML table. Shiny's client library raises
"shiny:value" events --> <!-- when outputs (in this case a HTML table)
are changed or assigned a --> <!-- value. These event listeners are
implemented in `ui.js`, and the HTML --> <!-- tables are fed to
Tabulator to render them appropriately in the DOM. -->

The 'Download Predictions' button uses this new Tabulator instance
to make the predictions downloadable in csv/pdf/xlsx formats.

### server.R

The `server.R` file implements the shiny-server functionality.

### model.R

The `model.R` file implements the COvid-19 Disease outcome prediction
model.

Imputation of parameters occurs *only* when they are empty (NA or non
numeric), according to the following value table.


| **Parameter**               | **Imputation Value** |
|-----------------------------|----------------------|
| Age                         | 66.679109811566      |
| Platelets (x10^6/L)         | 250097.699563434     |
| Eosinophils (x10^6/L)       | 63.8181665997054     |
| Neutrophils  (x10^6/L)      | 5525.89391927775     |
| Monocytes  (x10^6/L)        | 535.880366972477     |
| C-Reactive Protein (mg/L)   | 74.4896361594228     |
| Creatinine (mg/dL)          | 1.15657419376222     |
| Lactate Dehydrogenase (U/L) | 363.908290097421     |
| Sodium (Natremia; mmol/L)   | 138.426808936312     |
| Potassium (Kalemia; mmol/L) | 4.17844129554656     |
| Glucose (mg/dL)             | 124.285195339273     |
| D-dimer (ng/mL)             | 2122.15796236425     |

## Debugging

Since Shiny debugging is sometimes non-trivial, the `ui.js` file has
an event listener for manually debugging Shiny code. Shiny can send
arbitrary data to the browser session (see [Shiny
Documentation](https://shiny.rstudio.com/articles/communicating-with-js.html)),
sending a message with the `debug` identifier will print the message
to the browser console.

### Testing Predictions

The application must be tested manually for prediction correctness
using the browser console.

Procedure

1. In the browser console, run `load_test_data()`. This will load some test
   data into the table. 
2. Choose between CODOP-Ovt and CODOP-Unt.
3. Click on PREDICT
4. After the predictions are loaded, run `test_predictions_ovt()` or
   `test_predictions_unt()` depending on your previous selection. This
   will return two lists. The first lists the incorrect predictions,
   and the second lists the index of these predictions in the original data.
   
5. For additional debugging, you can run
   `load_specific_test_data(test_predictions_ovt()[1])` or
   `load_specific_test_data(test_predictions_unt()[1])` to modify the
   specific patient values that yield incorrect predictions.

