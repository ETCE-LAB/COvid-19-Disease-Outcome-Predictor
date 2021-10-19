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
// Initialise Editable table
var patientDataTable_Ovt = new Tabulator("#patientData-table-Ovt", {
    validationMode:"highlight",
    data:tabledataOvt,
    reactiveData:true,
    columns:[
	{title:"Age", field:"Age", sorter:"number", editor:true, mutator:"Numeric", validator:{
	    type:"min",
	    parameters:0
	}},
	{title:"Platelets<br/>(x10^6/L)", field:"Platelets (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Eosinophils<br/>(x10^6/L)", field:"Eosinophils (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Neutrophils<br/> (x10^6/L)", field:"Neutrophils  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Monocytes<br/> (x10^6/L)", field:"Monocytes  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"C-Reactive Protein<br/>(mg/L)", field:"C-Reactive Protein (mg/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Creatinine<br/>(mg/dL)", field:"Creatinine (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Lactate Dehydrogenase<br/>(U/L)", field:"Lactate Dehydrogenase (U/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Sodium<br/>(Natremia; mmol/L)", field:"Sodium (Natremia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Potassium<br/>(Kalemia; mmol/L)", field:"Potassium (Kalemia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"Glucose<br/>(mg/dL)", field:"Glucose (mg/dL)", sorter:"number", editor:true, mutator:"Numeric"},
	{title:"D-dimer<br/>(ng/mL)", field:"D-dimer (ng/mL)", sorter:"number", editor:true, mutator:"Numeric"}
    ],
    autoColumns:false,
    history:true,
    layout:"fitDataTable",
    layoutColumnsOnNewData:true,
    tooltips:true,
    //responsiveLayout:"collapse",
    resizableRows:true,
    resizableColumns:true});
// Event listeners for Add/Undo/Redo/Delete actions
// Function that sets the patientDataCSV_* attribute on the shiny-server session to compute the predictions
// The json data from the table is converted to csv and the Shiny input is set.
// Event listeners for Add/Undo/Redo/Delete actions

document.getElementById("add-patient-Ovt").addEventListener("click", function(){
    tabledataOvt.push({});
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
function renderOvtPredictions(){
	divv = document.getElementById("tableOvt");
	divv.children[0].id="tableOvt-output";
	tableOvt_Output = new Tabulator("#tableOvt-output", {
	    autoColumns:false,
    layout:"fitDataTable",
    layoutColumnsOnNewData:true,
    tooltips:true,
    //responsiveLayout:"collapse",
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

});

// Event listeners for downloading the predictions to csv

function downloadPredictions(choice){
    if(choice=="csv") {
	tableOvt_Output.download("csv", "Predictions.csv", {delimiter:","});
    }
    else if(choice=="xlsx"){
	tableOvt_Output.download("xlsx", "Predictions.xlsx", {sheetName:"Predictions"}); //download a xlsx file that has a sheet name of "MyData"
    }
    else if(choice=="pdf"){
	jsPDF = jspdf.jsPDF;
	tableOvt_Output.download("pdf", "Predictions.pdf", {
	    orientation:"landscape", //set page orientation to portrait
	    title:"Predictions", //add title to report
    // jsPDF:{
    //     unit:"in", //set units to inches
    // },
    // autoTable:{ //advanced table styling
    //     styles: {
    //         fillColor: [100, 255, 255]
    //     },
    //     columnStyles: {
    //         id: {fillColor: 255}
    //     },
    //     margin: {top: 60},
    // },
    // documentProcessing:function(doc){
    //     //carry out an action on the doc object
    // }
});
    }
}

document.getElementById("download-button").addEventListener("click", function(event){
    downloadPredictions($("#download-predictions-choice").val());
});
// Debug functions
$(document).on('shiny:bound', (event) => {
    console.log(event.name);
});

$(document).on('shiny:unbound', (event) => {
    console.log(event.name);
});
