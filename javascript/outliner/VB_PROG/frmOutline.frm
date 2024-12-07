VERSION 4.00
Begin VB.Form frmOutline 
   Caption         =   "Outline Generator"
   ClientHeight    =   2415
   ClientLeft      =   2640
   ClientTop       =   2430
   ClientWidth     =   7680
   Height          =   2775
   Left            =   2580
   LinkTopic       =   "Form1"
   ScaleHeight     =   2415
   ScaleWidth      =   7680
   Top             =   2130
   Width           =   7800
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   3120
      TabIndex        =   4
      Text            =   "<none>"
      Top             =   840
      Width           =   4335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Exit"
      Height          =   495
      Index           =   2
      Left            =   360
      TabIndex        =   2
      Top             =   1680
      Width           =   2295
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Generate Outline"
      Enabled         =   0   'False
      Height          =   495
      Index           =   1
      Left            =   360
      TabIndex        =   1
      Top             =   960
      Width           =   2295
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Select Data File"
      Height          =   495
      Index           =   0
      Left            =   360
      TabIndex        =   0
      Top             =   240
      Width           =   2295
   End
   Begin VB.Label Label1 
      Caption         =   "Current data file:"
      Height          =   255
      Left            =   3120
      TabIndex        =   3
      Top             =   600
      Width           =   1335
   End
   Begin MSComDlg.CommonDialog CD1 
      Left            =   1080
      Top             =   4080
      _Version        =   65536
      _ExtentX        =   847
      _ExtentY        =   847
      _StockProps     =   0
   End
End
Attribute VB_Name = "frmOutline"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click(Index As Integer)

Dim reply As Integer

Select Case Index
    Case 0
    ' Display File Open dialog with HTML file filter.
        CD1.InitDir = App.Path
        CD1.Filter = "HTML files (*.HTM, *.HTML)|*.HTML;*.HTM"
        CD1.ShowOpen
        DataFileName = CD1.filename
        If DataFileName = "" Then
            Command1(1).Enabled = False
            Text1.text = "<none>"
        Else
            Command1(1).Enabled = True
            Text1.text = DataFileName
        End If
    Case 1
        ProcessFile
    Case 2
        reply = MsgBox("Exit - are you sure?", vbYesNo + vbQuestion)
        If reply = vbYes Then End
End Select
        
End Sub



Public Sub ProcessFile()

Dim FN As Integer, buf As String
Dim Template(3) As String, data(2) As String
Dim Path As String, OutFileName As String
Dim TFile As String

' Prompt the user to enter an name for the output
' file then combines it with the path where the data file
' is located and add the HTML extension. If no name entered,
' exit the sub.


OutFileName = InputBox("Enter output file name (no extension):", _
        "Output File Name")
If OutFileName = "" Then Exit Sub

' Get path from input file name.
Path = Left$(CD1.filename, Len(CD1.filename) - Len(CD1.FileTitle))
OutFileName = Path & OutFileName & ".HTML"

' Get the template sections
TFile = Path & TEMPLATEFILE

If Dir$(TFile) = "" Then
    Dim Msg As String
    Msg = "The index template file " & TFile
    Msg = Msg & " cannot be found."
    MsgBox (Msg)
    Exit Sub
End If

FN = FreeFile
Open TFile For Input As #FN

' Get the first block of template code up to MARK1
buf = ""
Template(1) = ""
Dim found As Boolean
found = False
Do
    Template(1) = Template(1) & buf & vbCrLf
    Line Input #FN, buf
    If buf = MARK1 Then
        found = True
        Exit Do
    End If
Loop While Not EOF(FN)

If (Not found) Then
    MsgBox ("This is not a proper template file.")
    Close FN
    Exit Sub
End If

' Now get the second block of the template file.

buf = ""
Template(2) = ""
found = False
Do
    Template(2) = Template(2) & buf & vbCrLf
    Line Input #FN, buf
    If buf = MARK2 Then
        found = True
        Exit Do
    End If
Loop While Not EOF(FN)

If (Not found) Then
    MsgBox ("This is not a proper template file.")
    Close FN
    Exit Sub
End If

' Finally the third block.

buf = ""
Template(3) = ""
Do
    Template(3) = Template(3) & buf & vbCrLf
    Line Input #FN, buf
Loop While Not EOF(FN)
Close #FN


'**********
' processing of data file will go here
data(1) = GetDataBlock()
data(2) = "var num =" & Str$(numIndexEntries) & vbCrLf
data(2) = data(2) & "var theTitle = " & Chr$(34) & _
          docTitle & Chr$(34) & vbCrLf
'**********

' Now we can output the index file.

Debug.Print data(1)
Debug.Print data(2)

FN = FreeFile

Open OutFileName For Output As #FN

Print #FN, Template(1)
Print #FN, data(1)
Print #FN, Template(2)
Print #FN, data(2)
Print #FN, Template(3)

Close #FN

MsgBox ("Outline file generated successfully.")

End Sub


Public Function GetDataBlock() As String

'Processes the data HTML document and extracts the information
'required for the outline.

Dim buf As String, temp As String
Dim count As Integer, FN As Integer
Dim level As Integer, quoteType As Integer
Dim p1 As Integer, p2 As Integer, p1sq As Integer
Dim p1dq As Integer
Dim data(500) As indexEntry

count = 1

'Open the data file.
FN = FreeFile
Open DataFileName For Input As #FN

'Look for the title.
docTitle = ""
Do
    Line Input #FN, temp
    buf = UCase$(temp)
    If Left$(buf, 7) = "<TITLE>" Then
        p1 = InStr(7, buf, "</T")
        docTitle = Mid$(temp, 8, p1 - 8)
        Exit Do
    End If
Loop While Not EOF(FN)

' Rewind the file
Seek #FN, 1

'Loop once for each line in the data file.
Do
    Line Input #FN, temp
    
    'If the line doesn't start with <A we're not interested.
    If UCase$(Left$(temp, 2)) <> "<A" Then GoTo NotHead
    
    'Look for an <H1> tag.
    p1 = InStr(1, temp, "<H1", 1)
    If p1 <> 0 Then
        level = 1
        GoTo A:
    End If
    
    'Otherwise look for an <H2> tag.
    p1 = InStr(1, temp, "<H2", 1)
    If p1 <> 0 Then level = 2 Else GoTo NotHead
A:
    data(count).level = level
    
    'Look for the first ' or " after "name"
    p1 = InStr(1, temp, "name", 1)
    p1 = p1 + 5
    p1sq = InStr(p1, temp, Chr$(39))
    p1dq = InStr(p1, temp, Chr$(34))
    If (p1sq = 0 And p1dq = 0) Then GoTo NotHead
    If (p1sq > 0 And p1sq < p1dq) Then    ' Single quote used
        quoteType = 39
        p1 = p1sq
    Else                    ' Double quote used
        quoteType = 34
        p1 = p1dq
    End If
    
    ' Find the next occurence of the type of quotation mark.
    p2 = InStr(p1 + 1, temp, Chr$(quoteType))
    
    ' The name attribute of this heading is located between
    ' position p1 and p2.
    data(count).name = Mid$(temp, p1 + 1, p2 - p1 - 1)
    
    ' Now find the heading text.
    p1 = InStr(1, temp, "<H", 1)
    p2 = InStr(1, temp, "</H", 1)
    p1 = p1 + 4
    
    ' The heading text of this heading is located between
    ' position p1 and p2.
    data(count).text = Mid$(temp, p1, p2 - p1)
    count = count + 1

NotHead:
Loop While Not EOF(FN)

Close #FN

count = count - 1

'Now that we have the required information stored in data() we
'can generate the HTML code.
Dim i As Integer
buf = ""
For i = 1 To count
    buf = buf & "index[" & Str(i) & "].value = " & Chr$(34) _
          & data(i).text & Chr$(34) & vbCrLf
    buf = buf & "index[" & Str(i) & "].dest = " & Chr$(34) _
          & data(i).name & Chr$(34) & vbCrLf
    buf = buf & "index[" & Str(i) & "].level = " & _
          Str$(data(i).level) & vbCrLf
Next i

numIndexEntries = count

GetDataBlock = buf
End Function

