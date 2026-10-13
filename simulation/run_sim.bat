@echo off
REM ============================================================================
REM Automation Script: Compile & Run Vedic & Conventional Multiplier Simulations
REM ============================================================================

echo ========================================================================
echo  [1/4] Compiling 16-bit Vedic Multiplier...
echo ========================================================================
iverilog -o "%~dp0vedic_16x16_tb.vvp" -I "%~dp0..\rtl" "%~dp0..\rtl\vedic_2x2.v" "%~dp0..\rtl\vedic_4x4.v" "%~dp0..\rtl\vedic_8x8.v" "%~dp0..\rtl\vedic_16x16.v" "%~dp0..\tb\vedic_16x16_tb.v"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Vedic Multiplier compilation failed!
    exit /b %ERRORLEVEL%
)

echo ========================================================================
echo  [2/4] Executing Vedic Multiplier Verification...
echo ========================================================================
vvp "%~dp0vedic_16x16_tb.vvp"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Simulation execution failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================================
echo  [3/4] Compiling Conventional Multiplier Reference...
echo ========================================================================
iverilog -o "%~dp0conventional_multiplier_tb.vvp" "%~dp0..\rtl\conventional_multiplier.v" "%~dp0..\tb\conventional_multiplier_tb.v"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Conventional Multiplier compilation failed!
    exit /b %ERRORLEVEL%
)

echo ========================================================================
echo  [4/4] Executing Conventional Multiplier Verification...
echo ========================================================================
vvp "%~dp0conventional_multiplier_tb.vvp"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Conventional simulation execution failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================================
echo  Simulation completed! Waveforms saved in: simulation\
echo ========================================================================
