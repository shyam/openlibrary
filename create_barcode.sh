echo "Creating barcode for $1 ..."
barcode -b \"$1\" -t 1x1+200+375 -o tmp/$1.ps
echo "Converting postscript to png ..."
convert -density 100 tmp/$1.ps -flatten tmp/$1.png
echo "Cropping png ..."
convert tmp/$1.png -crop 256x256+285+380 ../shared/barcode_images/$1.png
rm tmp/$1.*