@echo off
REM ============================================================================
REM Automation Script: Open Vedic Multiplier VCD in GTKWave
REM ============================================================================

set VCD_FILE=%~dp0vedic_16x16.vcd

if not exist "%VCD_FILE%" (
    echo [ERROR] Waveform file "%VCD_FILE%" not found!
    echo Please run simulation\run_sim.bat first to generate the waveform.
    pause
    exit /b 1
)

where gtkwave >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    start gtkwave "%VCD_FILE%"
) else if exist "C:\iverilog\gtkwave\bin\gtkwave.exe" (
    start C:\iverilog\gtkwave\bin\gtkwave.exe "%VCD_FILE%"
) else (
    echo [ERROR] GTKWave executable not found in PATH or C:\iverilog\gtkwave\bin\
    pause
    exit /b 1
)
