@echo off
title Genshin Impact + ReShade
color 0f
mode con:cols=110 lines=25

REM ====================================================================================================
REM Script written by Shiro39
REM Slightly edited by a free RTGI dealer
REM Last modified on 2021-03-25
REM
REM This script is proved AS IS!
REM There is no quarantee that you would not get banned from playing the game with ReShade injected.
REM --You have been warned!--
REM Editors note, nobody has ever gotten banned in Genshin Impact or Star Rail by using Reshade.
REM ====================================================================================================

cls

REM ====================================================================================================
set "GenshinImpactPath=D:\Path\to\StarRail.exe"
REM Change the value of this variable to your StarRail.exe path. 
REM Only change what is after the = sign, don't touch GenshinImpactPath as that is part of code.
REM Example: "GenshinImpactPath=D:\Honkai Star Rail\Games\StarRail.exe"
REM ====================================================================================================

powershell -command Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
powershell -command Start-Process -FilePath Injector.exe StarRail.exe -Verb RunAs
powershell -command Start-Process -FilePath '%GenshinImpactPath%' -Verb RunAs
powershell -command Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted

exit