#! /bin/bash

sign_images()
{
echo "*******************************************************"
echo ""
echo "sign all images"

# check sign tool under current directoy
BIN_PATH=$(find . -type d -name sprd_secure_boot_tool | head -n 1)
if [ -z $BIN_PATH ]; then
    echo "There is no secure tool under directory $SRC_DIR, exit sign process."
    return 1
fi
BSC_BIN=$BIN_PATH"/BscGen"
VLR_BIN=$BIN_PATH"/VLRSign"
RSA_BIN=$BIN_PATH"/RSAKeyGen"

#set OUT_IMG_DIR value, just for test
OUT_IMG_DIR="test/release-sp9820a_12c20"

PN1="zouk4Gkey1"
PW1="zouk4g01"
PN2="zouk4Gkey2"
PW2="zouk4g02"
PN3="zouk4Gkey3"
PW3="zouk4g03"

# generate keys
$RSA_BIN -pn $PN1 -pw $PW1
$RSA_BIN -pn $PN2 -pw $PW2
$RSA_BIN -pn $PN3 -pw $PW3

# images need sign
IMG1=( 'fdl1.bin' 'u-boot-spl-16k.bin' )
IMG2=( 'fdl2.bin' 'u-boot.bin' )
IMG3=( 'boot.img' 'recovery.img' 'ltedsp.bin' 'ltegdsp.bin' 'ltemodem.bin' 'pmsys.bin' )

for img in ${IMG1[@]} 
do
    imgname=$OUT_IMG_DIR/$img
    echo $BSC_BIN -img $imgname -out $imgname -pw $PW1 -pn $PN1 -pw2 $PW2 -pn2 $PN2 
    $BSC_BIN -img $imgname -out $imgname -pw $PW1 -pn $PN1 -pw2 $PW2 -pn2 $PN2 
done

for img in ${IMG2[@]} 
do
    imgname=$OUT_IMG_DIR/$img
    echo $VLR_BIN -img $imgname -out $imgname -pw $PW2 -pn $PN2 -pw2 $PW3 -pn2 $PN3
    $VLR_BIN -img $imgname -out $imgname -pw $PW2 -pn $PN2 -pw2 $PW3 -pn2 $PN3
done

for img in ${IMG3[@]} 
do
    imgname=$OUT_IMG_DIR/$img
    echo $VLR_BIN -img $imgname -out $imgname -pw $PW3 -pn $PN3
    $VLR_BIN -img $imgname -out $imgname -pw $PW3 -pn $PN3
done
}

sign_images
