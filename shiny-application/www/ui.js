// This file contains the user interface changes made to accommodate
// the editable tables feature.

// Tabulator Mutator function to make sure all values are numeric

Tabulator.prototype.extendModule("mutator", "mutators", {
    Numeric:function(value, data, type, mutatorParams){
	if(  typeof(value)=="string" )
	{ return Number(value); }
	else {
	    return value;
	}
    },
});

// Define default columns and values

var tabledataOvt = [
    {"Age":"",
     "Platelets (x10^6/L)":"",
     "Eosinophils (x10^6/L)":"",
     "Neutrophils  (x10^6/L)":"",
     "Monocytes  (x10^6/L)":"",
     "C-Reactive Protein (mg/L)":"",
     "Creatinine (mg/dL)":"",
     "Lactate Dehydrogenase (U/L)":"",
     "Sodium (Natremia; mmol/L)":"",
     "Potassium (Kalemia; mmol/L)":"",
     "Glucose (mg/dL)":"",
     "D-dimer (ng/mL)":""}
];

var tabledataUnt = [
    {"Age":"",
     "Platelets (x10^6/L)":"",
     "Eosinophils (x10^6/L)":"",
     "Neutrophils  (x10^6/L)":"",
     "Monocytes  (x10^6/L)":"",
     "C-Reactive Protein (mg/L)":"",
     "Creatinine (mg/dL)":"",
     "Lactate Dehydrogenase (U/L)":"",
     "Sodium (Natremia; mmol/L)":"",
     "Potassium (Kalemia; mmol/L)":"",
     "Glucose (mg/dL)":"",
     "D-dimer (ng/mL)":""}
];

// Initialise Editable table
var patientDataTable_Ovt = new Tabulator("#patientData-table-Ovt", {
    data:tabledataOvt,
    reactiveData:true,
    columns:[
	{title:"Age", field:"Age", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Platelets (x10^6/L)", field:"Platelets (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Eosinophils (x10^6/L)", field:"Eosinophils (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Neutrophils  (x10^6/L)", field:"Neutrophils  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Monocytes  (x10^6/L)", field:"Monocytes  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"C-Reactive Protein (mg/L)", field:"C-Reactive Protein (mg/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Creatinine (mg/dL)", field:"Creatinine (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Lactate Dehydrogenase (U/L)", field:"Lactate Dehydrogenase (U/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Sodium (Natremia; mmol/L)", field:"Sodium (Natremia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Potassium (Kalemia; mmol/L)", field:"Potassium (Kalemia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Glucose (mg/dL)", field:"Glucose (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"D-dimer (ng/mL)", field:"D-dimer (ng/mL)", sorter:"number", editor:true, mutator:"Numeric"}
    ],
    autoColumns:false,
    history:true,
    layout:"fitColumns",
    layoutColumnsOnNewData:true,
    tooltips:true,
    // responsiveLayout:"hide",
    resizableRows:true,
    resizableColumns:true});

var patientDataTable_Unt = new Tabulator("#patientData-table-Unt", {
    data:tabledataUnt,
    reactiveData:true,
    columns:[
	{title:"Age", field:"Age", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Platelets (x10^6/L)", field:"Platelets (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Eosinophils (x10^6/L)", field:"Eosinophils (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Neutrophils  (x10^6/L)", field:"Neutrophils  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Monocytes  (x10^6/L)", field:"Monocytes  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"C-Reactive Protein (mg/L)", field:"C-Reactive Protein (mg/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Creatinine (mg/dL)", field:"Creatinine (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Lactate Dehydrogenase (U/L)", field:"Lactate Dehydrogenase (U/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Sodium (Natremia; mmol/L)", field:"Sodium (Natremia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Potassium (Kalemia; mmol/L)", field:"Potassium (Kalemia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"}, {title:"Glucose (mg/dL)", field:"Glucose (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"}, {title:"D-dimer (ng/mL)", field:"D-dimer (ng/mL)", sorter:"number", editor:true, mutator:"Numeric"}
    ],
    autoColumns:false,
    history:true,
    layout:"fitColumns",
    layoutColumnsOnNewData:true,
    tooltips:true,
    // responsiveLayout:"hide",
    resizableRows:true,
    resizableColumns:true});

// Event listeners for Add/Undo/Redo/Delete actions

document.getElementById("add-patient-Unt").addEventListener("click", function(){
    tabledataUnt.push({});
});

document.getElementById("undo-edit-Unt").addEventListener("click", function(){
    patientDataTable_Unt.undo();
});

document.getElementById("redo-edit-Unt").addEventListener("click", function(){
    patientDataTable_Unt.redo();
});

document.getElementById("del-row-Unt").addEventListener("click", function(){
    tabledataUnt.pop(); 
});

// Function that sets the patientDataCSV_* attribute on the shiny-server session to compute the predictions
// The json data from the table is converted to csv and the Shiny input is set.
var get_predictions_Unt = () => {
    Shiny.setInputValue("patientDataCSV_Unt", json2csv.parse(patientDataTable_Unt.getData(), {delimiter:"|"}));
};

// Event Listener for the 'Predict' action
document.getElementById("compute-predictions-Unt").addEventListener("click", get_predictions_Unt);

// Event listeners for Add/Undo/Redo/Delete actions
document.getElementById("add-patient-Ovt").addEventListener("click", function(){
    tabledataOvt.push({});
});

document.getElementById("undo-edit-Ovt").addEventListener("click", function(){
    patientDataTable_Ovt.undo();
});

document.getElementById("redo-edit-Ovt").addEventListener("click", function(){
    patientDataTable_Ovt.redo();

});

document.getElementById("del-row-Ovt").addEventListener("click", function(){
    tabledataOvt.pop();

});

// Function that sets the patientDataCSV_* attribute on the shiny-server session to compute the predictions
// The json data from the table is converted to csv and the Shiny input is set.

var get_predictions_Ovt = () => {
    Shiny.setInputValue("patientDataCSV_Ovt", json2csv.parse(patientDataTable_Ovt.getData(), {delimiter:"|"}));
};

document.getElementById("compute-predictions-Ovt").addEventListener("click", get_predictions_Ovt);

// Set the default value to prevent unnecessary outputs
//Shiny.setInputValue("patientDataCSV_Ovt", false);
//Shiny.setInputValue("patientDataCSV_Unt", false);


// Event listnener for debugging custom shiny messages
Shiny.addCustomMessageHandler('debug', function(message) {
    console.log(message); 
});

var tableOvt_Output = undefined;
var tableUnt_Output = undefined;

// Functions that render the rediction tables returned by shiny using
// the tabulator library
function renderUntPredictions(){
	divv = document.getElementById("tableUnt");
	divv.children[0].id="tableUnt-output";
	tableOvt_Output = new Tabulator("#tableUnt-output", {
	    reactiveData:true,
	    autoColumns:false,
	    layout:"fitColumns",
	    layoutColumnsOnNewData:true,
	    tooltips:true,
	    // responsiveLayout:"hide",
	    resizableRows:true,
	    resizableColumns:true});
}

function renderOvtPredictions(){
	divv = document.getElementById("tableOvt");
	divv.children[0].id="tableOvt-output";
	tableOvt_Output = new Tabulator("#tableOvt-output", {
	    reactiveData:true,
	    autoColumns:false,
	    layout:"fitColumns",
	    layoutColumnsOnNewData:true,
	    tooltips:true,
	    // responsiveLayout:"hide",
	    resizableRows:true,
	    resizableColumns:true});
}

// Event listener when the Shiny app updates a value. Used for
// detecting when the predictions are ready, so they can be rendered
// using the above functions.
$(document).on("shiny:value", function(event){
    if(event.name==='tableOvt'){
	console.log("Recieved Predictions Ovt");
	$("#tableOvt").html(event.value);
	renderOvtPredictions();
	event.preventDefault();
    }
    else if(event.name==="tableUnt"){
    console.log("Recieved Predictions Unt");
	$("#tableUnt").html(event.value);
	divv = document.getElementById("tableUnt");
	divv.children[0].id="tableUnt-output";
	tableUnt_Output = new Tabulator("#tableUnt-output", {
	    reactiveData:true,
	    autoColumns:false,
	    layout:"fitColumns",
	    layoutColumnsOnNewData:true,
	    tooltips:true,
	    // responsiveLayout:"hide",
	    resizableRows:true,
	    resizableColumns:true});
	event.preventDefault();
    }
});

// Event listeners for downloading the predictions to csv
document.getElementById("download-predictions-Ovt").addEventListener("click", function(event){
    tableOvt_Output.download("csv", "Ovt-Predictions.csv", {delimiter:","});
});

document.getElementById("download-predictions-Unt").addEventListener("click", function(event){
    tableUnt_Output.download("csv", "Unt-Predictions.csv", {delimiter:","});
});

// Debug functions
$(document).on('shiny:bound', (event) => {
    console.log(event.name);
});

$(document).on('shiny:unbound', (event) => {
    console.log(event.name);
});

// Shiny for some reason kills <input type=file> tags, that are not
// created using fileInput shiny modules, so Shiny events need to be
// unbound and then rebound for the app to work after the file has
// been added to the DOM

$("#upload-csv-Ovt").click(function(){
    Shiny.unbindAll();
});

// Event listener to render the uploaded csv file using tabulator CSV
// file is converted to json using the jquery-csv library

$("#upload-csv-Ovt").change(function(){
    Shiny.bindAll();
    csvFile = document.getElementById("upload-csv-Ovt");
    var reader = new FileReader();

    if(csvFile.files && csvFile.files[0]){
	reader.onload = (e) => {
	    csvRAW = e.target.result;
	    tabledataOvt = $.csv.toObjects(csvRAW);
	    patientDataTable_Ovt.setData(tabledataOvt);
	};
	reader.readAsText(csvFile.files[0]);
    }
    else{
	console.log("File not selected yet?");
    }
    renderOvtPredictions();
});

$("#upload-csv-Unt").click(function(){
    Shiny.unbindAll();
});

// Event listener to render the uploaded csv file using tabulator CSV
// file is converted to json using the jquery-csv library
$("#upload-csv-Unt").change(function(){
    Shiny.bindAll();
    csvFile = document.getElementById("upload-csv-Unt");
    var reader = new FileReader();

    if(csvFile.files && csvFile.files[0]){
	reader.onload = (e) => {
	    csvRAW = e.target.result;
	    tabledataUnt = $.csv.toObjects(csvRAW);
	    patientDataTable_Unt.setData(tabledataUnt);
	};
	reader.readAsText(csvFile.files[0]);
    }
    else{
	console.log("File not selected yet?");
    }
    renderUntPredictions();
});
