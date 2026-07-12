========================================================================
             EXCEL VBA MACRO: AUTOMATIC DROPDOWN PRINTER
========================================================================

This utility contains a VBA macro to automatically cycle through all 
names/values in an Excel dropdown list and print the sheet for each entry.

------------------------------------------------------------------------
   BEFORE YOU RUN: CONFIGURE THE VARIABLES
------------------------------------------------------------------------

Open the macro code and adjust these values to match your spreadsheet:

1. DATA: Change this to the sheet name where your list of names is stored.
2. A2:A38: Change this to the cell range where the names are located.
3. FRONT: Change this to the sheet name of the template/form you want to print.
4. R15: Change this to the exact cell where your dropdown menu is located.

------------------------------------------------------------------------
   HOW TO INSTALL AND RUN
------------------------------------------------------------------------

1. Open your Excel workbook.
2. Press [Alt + F11] to open the VBA Editor.
3. Click "Insert" in the top menu and select "Module".
4. Copy and paste the VBA code below into the empty module window.
5. Customize the sheet names and cell ranges as explained above.
6. Save and close the VBA Editor.
7. Press [Alt + F8] to open the Macro list.
8. Select "PrintAllStudents" and click "Run".

------------------------------------------------------------------------
   VBA MACRO CODE
------------------------------------------------------------------------

Sub PrintAllStudents()
    Dim studentList As Range
    Dim cell As Range
    
    ' Set the list of values to loop through (Sheet: DATA, Cells: A2 to A38)
    Set studentList = Sheets("DATA").Range("A2:A38")
    
    ' Loop through each name in the list
    For Each cell In studentList
        ' Place the current name into the dropdown cell (Sheet: FRONT, Cell: R15)
        Sheets("FRONT").Range("R15").Value = cell.Value
        
        ' Allow Excel to update the sheet formulas and layout before printing
        DoEvents
        
        ' Send the current sheet to the printer
        Sheets("FRONT").PrintOut
    Next cell
End Sub

========================================================================
