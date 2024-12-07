Attribute VB_Name = "Module1"
Option Explicit

' Template file name.
Public Const TEMPLATEFILE = "template.html"

' Markers in template file identifying locations
' for new information.
Public Const MARK1 = "[[one]]"
Public Const MARK2 = "[[two]]"

Global DataFileName As String
Global docTitle As String
Global numIndexEntries As Integer

Type indexEntry
    text As String
    name As String
    level As Integer
End Type
