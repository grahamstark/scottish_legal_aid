/****************************************************
     Author: Eric King
     Url: http://redrival.com/eak/index.shtml
     This script is free to use as long as this info is left in
     Featured on Dynamic Drive script library (http://www.dynamicdrive.com)
****************************************************/
     
/* some handly Javascript functions, collected (rather than written...) by Graham Stark
 * build a pop-up window and give it focus.
 **/

function ExampleWindow( mypage, rowTitle, colTitle ){
       myname = "Examples of"+rowTitle+"; "+colTitle;
       LeftPosition=(screen.width)?(screen.width-950)/2:100;
       TopPosition=(screen.height)?(screen.height-450)/2:100;
       settings='width=900,height=600,top='+TopPosition+',left='+LeftPosition+',scrollbars=yes,location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no';
       w = window.open(mypage,myname,settings);
       w.focus();
}
/* some handly Javascript functions, collected (rather than written...) by Graham Stark
 * build a pop-up window and give it focus.
 **/

function HouseholdWindow( mypage, rowTitle, colTitle ){
       myname = "Examples of"+rowTitle+"; "+colTitle;
       LeftPosition=(screen.width)?(screen.width-950)/2:100;
       TopPosition=(screen.height)?(screen.height-450)/2:100;
       settings='width=600,height=800,top='+TopPosition+',left='+LeftPosition+',scrollbars=yes,location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no';
       w = window.open(mypage,myname,settings);
       w.focus();
}

