#!/bin/sh

$pngdir=png

if [ -d $pngdir ]; then
  mkdir png
fi

echo "Generating uptime box plots..."
R --slave < uptime-boxplots.R | grep "TRUE"

echo "Generating bandwidth box plots..."
R --slave < bandwidth-boxplots.R | grep "TRUE"

echo "Generating uptime histograms..."
R --slave < uptime-histograms.R | grep "TRUE"

echo "Generating bandwidth pie charts..."
R --slave < bandwidth-piecharts.R | grep "TRUE"

echo "Generating bandwidth/uptime bar chart..."
R --slave < bandwidth-uptime-barchart.R | grep "TRUE"

echo "Generating bandwidth histograms..."
R --slave < bandwidth-histograms.R | grep "TRUE"
