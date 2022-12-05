#!/bin/zsh
#
# Script to run the ROMS model in 1-D configuration
#

$GAWK=/home/johor1356/opt/bin/$GAWK

PROJECT_DIR=/home/johor1356/simulations/Masfjorden/M24_2015

DATA_DIR=/home/johor1356/scratch/Fjords-1D/Masfjorden/

OUTPUT_DIR=$PROJECT_DIR/Output

OMP_NUM_THREADS=1

# Create ouput dir if it doesnt exist

if [ -d "$OUTPUT_DIR" ]
then
    echo "$OUTPUT_DIR exists."
else
	mkdir -p $OUTPUT_DIR
fi

ROMS=$PROJECT_DIR/romsO

# Run parameters

MASTER_INPUT=/home/johor1356/simulations/Masfjorden/mf_1d.in

TITLE=MF_1D_M24_GS2019114

RUN_TAG=TEST1Y

APP_CPP=MF_1D

N=120
Vtransform=2
Vstretching=4
theta_s=7
theta_b=6
tcline=200

NTIMES=52704
DT=600.0d0
NDTFAST=30

NHIS=80
NAVG=80
NDIA=144

DSTART=5752.0d0

FRCYSTART=2015
FRCYEND=2016

FRCMSTART=1
FRCMEND=12

GRDNAME=$DATA_DIR/mf_1d_grd.nc
ININAME=$DATA_DIR/initial/m24_ini_gs2019114_2015.nc
FRCNAME=forcing/mf_m24_frc_


RSTNAME=$OUTPUT_DIR/$TITLE"_"$RUN_TAG"_rst.nc"

HISNAME=$OUTPUT_DIR/$TITLE"_"$RUN_TAG"_his.nc"

AVGNAME=$OUTPUT_DIR/$TITLE"_"$RUN_TAG"_avg.nc"

DIANAME=$OUTPUT_DIR/$TITLE"_"$RUN_TAG"_dia.nc"

# Update input file

padtowidth=2

INPUT=$TITLE"_"$RUN_TAG".in"

cp $MASTER_INPUT $INPUT

TMP=$TITLE"_"$RUN_TAG

$GAWK -i inplace -v awkvar="$TMP" 'NR==68 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$APP_CPP" 'NR==72 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$N" 'NR==97 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$Vtransform" '/Vtransform ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$Vstretching" '/Vstretching ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$theta_s" '/THETA_S ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$theta_b" '/THETA_B ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$tcline" '/TCLINE ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$NTIMES" 'NR==225 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$DT" 'NR==226 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$NDTFAST" 'NR==227 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$DSTART" 'NR==423 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$NHIS" '/NHIS ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$NAVG" '/NAVG ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$NDIA" '/NDIA ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$GRDNAME" 'NR==964 {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$ININAME" 'NR==965 {$3=awkvar}; {print}' $INPUT
m=$(printf "%0*d\n" $padtowidth $FRCMSTART)
FRCFILES=$DATA_DIR"/"$FRCYSTART"_"$m".nc|"
#$GAWK -i inplace -v awkvar="$FRCFILES" 'NR==1051 {$3=awkvar}; {print}' $INPUT

let "FRCMEND-=1" 
FRCFILES=""
for (( y=$FRCYSTART; y<=$FRCYEND; y++ ))
do
	for (( m=$FRCMSTART; m<=$FRCMEND; m++ ))
	do
		#FRCFILES+=$(printf "%s|\n" $DATA_DIR"/mf_m26_frc_"$y"_"$m".nc")
		mm=$(printf "%0*d\n" $padtowidth $m)
                FRCFILES+=$DATA_DIR"/"$FRCNAME$y"_"$mm".nc|"$'\n'
	done	
done
let "FRCMEND+=1"
mm=$(printf "%0*d\n" $padtowidth $FRCMEND)
FRCFILES+=$DATA_DIR"/"$FRCNAME$FRCYEND"_"$mm".nc"
#echo "$FRCFILES"
$GAWK -i inplace -v awkvar="$FRCFILES" '/FRCNAME ==/ {$3=awkvar}; {print}' $INPUT


$GAWK -i inplace -v awkvar="$RSTNAME" '/RSTNAME ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$HISNAME" '/HISNAME ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$AVGNAME" '/AVGNAME ==/ {$3=awkvar}; {print}' $INPUT
$GAWK -i inplace -v awkvar="$DIANAME" '/DIANAME ==/ {$3=awkvar}; {print}' $INPUT

# Run model

export OMP_NUM_THREADS

LOG=log.$RUN_TAG

$ROMS < $INPUT > log

cp -v log $OUTPUT_DIR/$LOG
