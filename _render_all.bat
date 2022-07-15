@set OPENSCAD="C:\Program Files\OpenSCAD\openscad.exe"
@set PYTHON="C:\Users\Vector\Anaconda3\python.exe"
@set INP="F(star)P Newtonian.scad"


@set FOLDER=D80F800
mkdir %FOLDER%
for %%p in ("Spider" "Primary Mount" "View Mount" "Tripod Strap" "Primary Aligner" "Aiming Reticle", "Micro Dobs Print Layout") do (
  %OPENSCAD% -p "F(star)P Newtonian.json" -P %FOLDER% -D "part2=\"%%~p\"" --export-format binstl -o "%FOLDER%\%FOLDER% %%~p.stl" %INP%
  %PYTHON% canonicalize.py "%FOLDER%\%FOLDER% %%~p.stl"
)


@set FOLDER=D114F900
mkdir %FOLDER%
for %%p in ("Primary Mount" "Spider" "View Mount" "Tripod Strap" "Primary Aligner" "Aiming Reticle" "Tube Bottom" "Tube Middle" "Tube Top", "Micro Dobs Print Layout") do (
  %OPENSCAD% -p "F(star)P Newtonian.json" -P %FOLDER% -D "part2=\"%%~p\"" --export-format binstl -o "%FOLDER%\%FOLDER% %%~p.stl" %INP%
  %PYTHON% canonicalize.py "%FOLDER%\%FOLDER% %%~p.stl"
)


@set FOLDER=Accessories
mkdir %FOLDER%
for %%p in ("Eyepiece Mount" "Canon EF Mount" "Focus Estimator" "ESP32-Cam Mount") do (
  %OPENSCAD% -D "part2=\"%%~p\"" --export-format binstl -o "%FOLDER%\%%~p.stl" %INP%
  %PYTHON% canonicalize.py "%FOLDER%\%%~p.stl"
)


:end
pause
