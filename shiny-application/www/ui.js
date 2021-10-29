// This file contains the user interface changes made to accommodate
// the editable tables feature.

// Simple function that can check if an element is in the viewport https://coderwall.com/p/fnvjvg/jquery-test-if-element-is-in-viewport

$.fn.isOnScreen = function(){
    
    var win = $(window);
    
    var viewport = {
        top : win.scrollTop(),
        left : win.scrollLeft()
    };
    viewport.right = viewport.left + win.width();
    viewport.bottom = viewport.top + win.height();
    
    var bounds = this.offset();
    bounds.right = bounds.left + this.outerWidth();
    bounds.bottom = bounds.top + this.outerHeight();
    
    return (!(viewport.right < bounds.left || viewport.left > bounds.right || viewport.bottom < bounds.top || viewport.top > bounds.bottom));
    
};

// Tabulator Mutator function to make sure all values are numeric

Tabulator.prototype.extendModule("mutator", "mutators", {
    Numeric:function(value, data, type, mutatorParams){
	if(  typeof(value)=="string" && value != "" )
	{ return Number(value.replaceAll(",", ".")); }
	else if ( typeof(value) == "number" ) {
	    return value;
	}
	else {
	    return "";
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
    autoColumns:false,
    history:true,
    layout:"fitDataTable",
    layoutColumnsOnNewData:true,
    tooltips:true,
    //responsiveLayout:"collapse",
    resizableRows:true,
    resizableColumns:true,
    validationFailed:function(cell, value, validators){
	errorMessage = undefined;
	fieldname = cell._cell.column.field;
	fieldnameid = fieldname.substr(0,5)+"_error";

	errorCallbackFunction = (event) => {
	    $(event.target).next().remove();
	    $(event.target).remove();
	    if(!$(cell.getElement()).isOnScreen() && !cell.validate())
		$.scrollTo(cell._cell.element, 100, {margin:true, axis:"xy", offset:{top:-100, left:-100}});
	};

	if (validators[0].type == "max"){
	    errorMessage = fieldname+" should be at most "+validators[0].parameters;
	}
	else if(validators[0].type == "min"){
	    errorMessage = fieldname+" should be at least "+validators[0].parameters;
	}

	if (!$("#"+fieldnameid).length){
	    $("#errorPane").append("<label class='validation-error' id='"+fieldnameid+"'>"+errorMessage+"</label><br/>");
	    if(!$('#'+fieldnameid).isOnScreen())
		$.scrollTo('#'+fieldnameid, 200, {margin:true, offset:-200});
	    $("#"+fieldnameid).click(errorCallbackFunction);
	}
	return true;
    },
    columns:[
	{title:"Age", field:"Age", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:120"], editorParams:{elementAttributes:{placeholder:"[0,120]"}}},
	{title:"Platelets<br/>(x10^6/L)", field:"Platelets (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:1000", "max:1420000"], editorParams:{elementAttributes:{placeholder:"[1000,1420000]"}}},
	{title:"Eosinophils<br/>(x10^6/L)", field:"Eosinophils (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:4850"], editorParams:{elementAttributes:{placeholder:"[0,4850]"}}},
	{title:"Neutrophils<br/> (x10^6/L)", field:"Neutrophils  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:150000"], editorParams:{elementAttributes:{placeholder:"[0,150000]"}}},
	{title:"Monocytes<br/> (x10^6/L)", field:"Monocytes  (x10^6/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:9999"], editorParams:{elementAttributes:{placeholder:"[0,9999]"}}},
	{title:"C-Reactive Protein<br/>(mg/L)", field:"C-Reactive Protein (mg/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:1000"], editorParams:{elementAttributes:{placeholder:"[0,1000]"}}},
	{title:"Creatinine<br/>(mg/dL)", field:"Creatinine (mg/dL)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:19.74"], editorParams:{elementAttributes:{placeholder:"[0,19.74]"}}},
	{title:"Lactate Dehydrogenase<br/>(U/L)", field:"Lactate Dehydrogenase (U/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:16018"], editorParams:{elementAttributes:{placeholder:"[0,16018]"}}},
	{title:"Sodium<br/>(Natremia; mmol/L)", field:"Sodium (Natremia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:105", "max:190"], editorParams:{elementAttributes:{placeholder:"[105,190]"}}},
	{title:"Potassium<br/>(Kalemia; mmol/L)", field:"Potassium (Kalemia; mmol/L)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:1.8", "max:9.8"], editorParams:{elementAttributes:{placeholder:"[1.8,9.8]"}}},
	{title:"Glucose<br/>(mg/dL)", field:"Glucose (mg/dL)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:15", "max:1100"], editorParams:{elementAttributes:{placeholder:"[15,1100]"}}},
	{title:"D-dimer<br/>(ng/mL)", field:"D-dimer (ng/mL)", sorter:"number", editor:true, mutator:"Numeric", validator:["min:0", "max:575000"], editorParams:{elementAttributes:{placeholder:"[0,575000]"}}}
    ]});

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
    errorCells = patientDataTable_Ovt.validate();
    if(errorCells === true)
	Shiny.setInputValue("patientDataCSV_Ovt", json2csv.parse(patientDataTable_Ovt.getData(), {delimiter:"|"}));
    else
    {
	$.scrollTo(errorCells[0].getElement(), 100, {offset:{top:-100, left:-100}});
    }
};

document.getElementById("compute-predictions-Ovt").addEventListener("click", get_predictions_Ovt);

// Set the default value to prevent unnecessary outputs
//Shiny.setInputValue("patientDataCSV_Ovt", false);
//Shiny.setInputValue("patientDataCSV_Unt", false);


// Event listnener for debugging custom shiny messages
Shiny.addCustomMessageHandler('debug', function(message) {
    console.log(message); 
});

Shiny.addCustomMessageHandler('CODOP-Predictions', function(message){
    renderOvtPredictions2(message);
    console.log(message);
});

var tableOvt_Output = undefined;

function renderOvtPredictions2(predictions){
    prediction_data = [];
    for(i=0; i<predictions["Age"].length; i++){
	prediction_data.push({
	    "Prediction":predictions["Prediction"][i],
	    "Binary Prediction":predictions["Binary Prediction"][i],
	    "Age":predictions["C-Reactive Protein (mg/L)"][i],
	    "Platelets (x10^6/L)":predictions["Platelets (x10^6/L)"][i],
	    "Eosinophils (x10^6/L)":predictions["Eosinophils (x10^6/L)"][i],
	    "Neutrophils  (x10^6/L)":predictions["Neutrophils  (x10^6/L)"][i],
	    "Monocytes  (x10^6/L)":predictions["Monocytes  (x10^6/L)"][i],
	    "C-Reactive Protein (mg/L)":predictions["C-Reactive Protein (mg/L)"][i],
	    "Creatinine (mg/dL)":predictions["Creatinine (mg/dL)"][i],
	    "Lactate Dehydrogenase (U/L)":predictions["Lactate Dehydrogenase (U/L)"][i],
	    "Sodium (Natremia; mmol/L)":predictions["Sodium (Natremia; mmol/L)"][i],
	    "Potassium (Kalemia; mmol/L)":predictions["Potassium (Kalemia; mmol/L)"][i],
	    "Glucose (mg/dL)":predictions["Glucose (mg/dL)"][i],
	    "D-dimer (ng/mL)":predictions["D-dimer (ng/mL)"][i]});
    }
    tableOvt_Output = new Tabulator("#tableOvt-output", {
	reactiveData:true,
	autoColumns:false,
	layout:"fitDataTable",
	layoutColumnsOnNewData:true,
	tooltips:true,
	//responsiveLayout:"collapse",
	resizableRows:true,
	resizableColumns:true,
	data:prediction_data,
	columns:[
	    {title:"Prediction", field:"Prediction"},
	    {title:"Binary<br/>Prediction", field: "Binary Prediction"},
	{title:"Age", field:"Age", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:120"]},
	{title:"Platelets<br/>(x10^6/L)", field:"Platelets (x10^6/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:1000", "max:1420000"]},
	{title:"Eosinophils<br/>(x10^6/L)", field:"Eosinophils (x10^6/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:4850"]},
	{title:"Neutrophils<br/> (x10^6/L)", field:"Neutrophils  (x10^6/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:150000"]},
	{title:"Monocytes<br/> (x10^6/L)", field:"Monocytes  (x10^6/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:9999"]},
	{title:"C-Reactive Protein<br/>(mg/L)", field:"C-Reactive Protein (mg/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:1000"]},
	{title:"Creatinine<br/>(mg/dL)", field:"Creatinine (mg/dL)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:19.74"]},
	{title:"Lactate Dehydrogenase<br/>(U/L)", field:"Lactate Dehydrogenase (U/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:16018"]},
	{title:"Sodium<br/>(Natremia; mmol/L)", field:"Sodium (Natremia; mmol/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:105", "max:190"]},
	{title:"Potassium<br/>(Kalemia; mmol/L)", field:"Potassium (Kalemia; mmol/L)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:1.8", "max:9.8"]},
	{title:"Glucose<br/>(mg/dL)", field:"Glucose (mg/dL)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:15", "max:1100"]},
	{title:"D-dimer<br/>(ng/mL)", field:"D-dimer (ng/mL)", sorter:"number", editor:false, mutator:"Numeric", validator:["min:0", "max:575000"]}
    ]
    });
    if(!$("#download-button").isOnScreen())
    $.scrollTo("#download-button", 300, {axis:"y"});
}
function renderOvtPredictions(predictions){
    divv = document.getElementById("tableOvt");
    divv.children[0].id="tableOvt-output";
    tableOvt_Output = new Tabulator("#tableOvt-output", {
	validationMode:"highlight",
	reactiveData:true,
	autoColumns:false,
	history:true,
	layout:"fitData",
	layoutColumnsOnNewData:true,
	tooltips:true,
	//responsiveLayout:"collapse",
	resizableRows:true,
	resizableColumns:true
    });
}

// Event listener when the Shiny app updates a value. Used for
// detecting when the predictions are ready, so they can be rendered
// using the above functions.
$(document).on("shiny:value", function(event){
    if(event.name==='tableOvt'){
	console.log("Recieved Predictions");
	//$("#tableOvt").html(event.value);
	//renderOvtPredictions2();
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
