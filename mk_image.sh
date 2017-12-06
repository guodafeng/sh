#!/bin/bash

function copy_target_files()
{
    if [ $# != 2 ] || [ ! -d $1 ]; then
        echo echo "usage: ${FUNCNAME[0]} <image out dir> <target name>"
        return 255
    fi
    local imgout_dir=$1
    local target_name=$2
    local target_files_zip=$(ls -lt out/target/product/${target_name}/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip | tail -1 | awk '{print $NF}')

    if [ -f "${target_files_zip}" ]; then
        cp -f ${target_files_zip} ${imgout_dir}/target_files.zip
        zip -q -d ${imgout_dir}/target_files.zip SYSTEM/* /DATA* /IMAGES*
    else
        echo "copy ota target files failed"
        return 1
    fi
}

# if sec_boot build by mk_aliphone_sign.sh
grep -rin "YUNOS_SUPPORT_SEC_BOOT=true"  out/options.txt 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo "****secure_boot version!!***"
    SEC_BOOT=true
fi

copy_image()
{
echo "*******************************************************"
echo ""
echo "copy images to image_out..."

TARGET_NAME=`cat out/board_dir.txt`
OUT_IMG_DIR=release-${TARGET_NAME}
rm -rf ${OUT_IMG_DIR}
mkdir -p ${OUT_IMG_DIR}
TARGET_NAME=`cat out/projectName.txt`
TOOLS=aliyunos/build/tools
if [ "$PRO_NAME" = "sp9820a_c110" -o "$PRO_NAME" = "sp9820a_12c20" ];then
    if [ "$TARGET_NAME" == "sp9820a_c110_2342A" -o "$TARGET_NAME" == "sp9820a_12c20_2342A" ] ; then
    PERL_FILE=pac_PikeL-3M_2342A.pl
    else
    PERL_FILE=pac_PikeL-3M.pl
    fi
elif [ "$PRO_NAME" = "sp9820a_12c10" ];then
    PERL_FILE=pac_PikeL-3M-12C10.pl
else
    #sp9820a_refh10
    PERL_FILE=pac_PikeL-3M-refh10.pl
fi

#copy xml/bin files
TARGET_NAME=`cat out/projectName.txt`
SE_XML_FILE=PikeL3ModeMarlinAndroid6.0_SE.xml
if [ "$SEC_BOOT" = "true" ];then
    if [ "$TARGET_NAME" == "sp9820a_c110_2342A" -o "$TARGET_NAME" == "sp9820a_12c20_2342A" ] ; then
    XML_FILE=PikeL3ModeMarlinAndroid6.0_SE_2342A.xml
    else
    XML_FILE=PikeL3ModeMarlinAndroid6.0_SE.xml
    fi
else
    if [ "$TARGET_NAME" == "sp9820a_c110_2342A" -o "$TARGET_NAME" == "sp9820a_12c20_2342A" ] ; then
    XML_FILE=PikeL3ModeMarlinAndroid6.0_2342A.xml
    else
    XML_FILE=PikeL3ModeMarlinAndroid6.0.xml
    fi
fi

CRC_FILE=UpdatedPacCRC_Linux
#OUT_IMG_DIR=./image_out/build_img

cp out/projectName.txt ${OUT_IMG_DIR}
cp out/options.txt ${OUT_IMG_DIR}
cp out/board_dir.txt ${OUT_IMG_DIR}
cp out/target/product/$PRO_NAME/system/build.prop ${OUT_IMG_DIR}
cp out/target/product/$PRO_NAME/obj/PACKAGING/systemimage_intermediates/system_image_info.txt ${OUT_IMG_DIR}
copy_target_files "$OUT_IMG_DIR" "$PRO_NAME"

echo "copy fdl1.bin ..."
cp out/target/product/$PRO_NAME/fdl1.bin ${OUT_IMG_DIR}
echo "copy fdl2.bin ..."
cp out/target/product/$PRO_NAME/fdl2.bin  ${OUT_IMG_DIR}
echo "copy u-boot-spl-16k.bin ..."
cp out/target/product/$PRO_NAME/u-boot-spl-16k.bin ${OUT_IMG_DIR}
echo "copy u-boot.bin ..."
cp out/target/product/$PRO_NAME/u-boot.bin ${OUT_IMG_DIR}
echo "copy boot.img ..."
cp out/target/product/$PRO_NAME/boot.img ${OUT_IMG_DIR}
echo "copy recovery.img ..."
cp out/target/product/$PRO_NAME/recovery.img ${OUT_IMG_DIR}

if [ "$PRO_NAME" = "sp9820a_c110" -o  "$PRO_NAME" = "sp9820a_12c20" ];then
    echo "copy system_b256k_p4k.img ..."
    cp out/target/product/$PRO_NAME/system_b256k_p4k.img ${OUT_IMG_DIR}
    echo "copy userdata_b256k_p4k.img ..."
    cp out/target/product/$PRO_NAME/userdata_b256k_p4k.img ${OUT_IMG_DIR}
    echo "copy cache_b256k_p4k.img ..."
    cp out/target/product/$PRO_NAME/cache_b256k_p4k.img ${OUT_IMG_DIR}
    echo "copy prodnv_b256k_p4k.img ..."
    cp out/target/product/$PRO_NAME/prodnv_b256k_p4k.img ${OUT_IMG_DIR}
    echo "copy system_b128k_p2k.img ..."
    cp out/target/product/$PRO_NAME/system_b128k_p2k.img ${OUT_IMG_DIR}
    echo "copy userdata_b128k_p2k.img ..."
    cp out/target/product/$PRO_NAME/userdata_b128k_p2k.img ${OUT_IMG_DIR}
    echo "copy cache_b128k_p2k.img ..."
    cp out/target/product/$PRO_NAME/cache_b128k_p2k.img ${OUT_IMG_DIR}
    echo "copy prodnv_b128k_p2k.img ..."
    cp out/target/product/$PRO_NAME/prodnv_b128k_p2k.img ${OUT_IMG_DIR}

    cd ${OUT_IMG_DIR}
    ln -s system_b128k_p2k.img system.img
    cd - > /dev/null
else
    #sp9820a_refh10
    echo "copy system.img ..."
    cp out/target/product/$PRO_NAME/system.img ${OUT_IMG_DIR}
    echo "copy userdata.img ..."
    cp out/target/product/$PRO_NAME/userdata.img ${OUT_IMG_DIR}
    echo "copy cache.img ..."
    cp out/target/product/$PRO_NAME/cache.img ${OUT_IMG_DIR}
    echo "copy prodnv.img ..."
    cp out/target/product/$PRO_NAME/prodnv.img ${OUT_IMG_DIR}
fi

echo "copy file_contexts ..."
cp out/target/product/$PRO_NAME/root/file_contexts ${OUT_IMG_DIR}


echo "copy $PERL_FILE ..."
cp $TOOLS/$PERL_FILE ${OUT_IMG_DIR}
cp $TOOLS/pack_pac.sh ${OUT_IMG_DIR}
echo "copy $XML_FILE ..."
cp $PROJECT_DEV_PATH/$XML_FILE ${OUT_IMG_DIR}
echo "copy $SE_XML_FILE ..."
cp $PROJECT_DEV_PATH/$SE_XML_FILE ${OUT_IMG_DIR}
echo "copy $CRC_FILE ..."
cp $TOOLS/$CRC_FILE ${OUT_IMG_DIR}

echo "copying CP0&CP1 modem files"
#copy bins
#echo "copying ltenvitem.bin"
#cp ${VENDOR_BIN}/EXEC_KERNEL_IMAGE0.bin ${OUT_IMG_DIR}
echo "copying fbootlogo.bmp"
cp ${VENDOR_BIN}/fbootlogo.bmp ${OUT_IMG_DIR}
echo "copying ltedsp.bin"
cp ${VENDOR_BIN}/ltedsp.bin ${OUT_IMG_DIR}
echo "copying ltegdsp.bin"
cp ${VENDOR_BIN}/ltegdsp.bin ${OUT_IMG_DIR}
echo "copying ltenvitem.bin"
cp ${VENDOR_BIN}/ltenvitem.bin ${OUT_IMG_DIR}
echo "copying pmsys.bin"
cp ${VENDOR_BIN}/pmsys.bin ${OUT_IMG_DIR}

#echo "copying CP2 WCN files"
echo "copying ltemodem.bin"
cp ${VENDOR_BIN}/ltemodem.bin ${OUT_IMG_DIR}
#echo "copying wcnfdl.bin to fdl1_wcn.bin"
#cp ${VENDOR_BIN}/wcnfdl.bin ${OUT_IMG_DIR}

echo "copying Logo files"
cp ${VENDOR_BIN}/sprd_320240.bmp ${OUT_IMG_DIR}

echo "copying wcnfdl files"
cp ${VENDOR_BIN}/wcnfdl.bin ${OUT_IMG_DIR}

echo "copying wcnmodem files"
cp ${VENDOR_BIN}/wcnmodem.bin ${OUT_IMG_DIR}

echo "copying depack_PAC, signing platform need this"
cp -f aliyunos/build/tools/depack_PAC ${OUT_IMG_DIR}

echo "copy images to image_out Done!"
echo ""
echo "*******************************************************"
}

create_pac()
{
echo "*******************************************************"
echo ""
echo "create $release_version.pac file..."
cd ${OUT_IMG_DIR}

if [ "$PRO_NAME" = "sp9820a_c110" -o "$PRO_NAME" = "sp9820a_12c20" ];then
    if [ "$TARGET_NAME" == "sp9820a_c110_2342A" -o "$TARGET_NAME" == "sp9820a_12c20_2342A" ] ; then
/usr/bin/perl $PERL_FILE $release_version.pac "PikeL3ModeMarlinAndroid6.0" $release_version $XML_FILE fdl1.bin fdl2.bin ltenvitem.bin prodnv_b256k_p4k.img u-boot-spl-16k.bin ltemodem.bin ltedsp.bin ltegdsp.bin pmsys.bin boot.img recovery.img system_b256k_p4k.img userdata_b256k_p4k.img sprd_320240.bmp fbootlogo.bmp cache_b256k_p4k.img u-boot.bin prodnv_b128k_p2k.img system_b128k_p2k.img userdata_b128k_p2k.img cache_b128k_p2k.img wcnfdl.bin wcnmodem.bin
    else
/usr/bin/perl $PERL_FILE $release_version.pac "PikeL3ModeMarlinAndroid6.0" $release_version $XML_FILE fdl1.bin fdl2.bin ltenvitem.bin prodnv_b256k_p4k.img u-boot-spl-16k.bin ltemodem.bin ltedsp.bin ltegdsp.bin pmsys.bin boot.img recovery.img system_b256k_p4k.img userdata_b256k_p4k.img sprd_320240.bmp fbootlogo.bmp cache_b256k_p4k.img u-boot.bin prodnv_b128k_p2k.img system_b128k_p2k.img userdata_b128k_p2k.img cache_b128k_p2k.img
    fi
elif [ "$PRO_NAME" = "sp9820a_12c10" ];then
    /usr/bin/perl $PERL_FILE $release_version.pac "PikeL3ModeMarlinAndroid6.0" $release_version $XML_FILE fdl1.bin fdl2.bin ltenvitem.bin prodnv.img u-boot-spl-16k.bin ltemodem.bin ltedsp.bin ltegdsp.bin pmsys.bin boot.img recovery.img system.img userdata.img sprd_320240.bmp fbootlogo.bmp cache.img u-boot.bin wcnfdl.bin wcnmodem.bin
else
#sp9820a_refh10
/usr/bin/perl $PERL_FILE $release_version.pac "PikeL3ModeMarlinAndroid6.0" $release_version $XML_FILE fdl1.bin fdl2.bin ltenvitem.bin prodnv.img u-boot-spl-16k.bin ltemodem.bin ltedsp.bin ltegdsp.bin pmsys.bin boot.img recovery.img system.img userdata.img sprd_320240.bmp fbootlogo.bmp cache.img u-boot.bin
fi

cd ../

#rm -rf build_img

cd ../
echo "creat $release_version.pac file Done!"
echo ""
echo "*******************************************************"
}

sign_images()
{
echo "*******************************************************"
echo ""
echo "Sign all images"

# check sign tool under current directoy
BIN_PATH=$(find . -type d -name sprd_secure_boot_tool | head -n 1)
if [ -z $BIN_PATH ]; then
    echo "There is no secure tool under directory $SRC_DIR, exit sign process."
    return 1
fi
BSC_BIN=$BIN_PATH"/BscGen"
VLR_BIN=$BIN_PATH"/VLRSign"
RSA_BIN=$BIN_PATH"/RSAKeyGen"

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

# sign images
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


zip_images()
{
echo "*******************************************************"
echo ""
echo "zip all images for signing by YunOS"
cd ${OUT_IMG_DIR}
zip -r ../$release_version.zip  ./*

cd ../
echo "zip all images, done!"
echo ""
echo "*******************************************************"
}

if [ $# -eq 1 ] && [ "$1" = "-h" ] ; then
    echo "--------------------------------------------------------------------"
	echo "usage:   `basename $0` [release_version]"
	echo ""
	echo "e.g.:    `basename $0` ALIYUNOS_3.1.0_SPRD_9830_DEV"
	echo "--------------------------------------------------------------------"
    exit 0
fi

TARGET_NAME=`cat out/projectName.txt`
PRO_NAME=`cat out/board_dir.txt`
PROJECT_DEV_PATH=device/sprd/scx35l/$PRO_NAME
if [ "$PRO_NAME" = "sp9820a_c110" -o "$PRO_NAME" = "sp9820a_12c20" ];then
    if [ "$TARGET_NAME" == "sp9820a_c110_native" ] ; then
        VENDOR_BIN=$PROJECT_DEV_PATH/modem_bins/Modem_No_TDS
    elif [ "$TARGET_NAME" == "sp9820a_c110_2342A" -o "$TARGET_NAME" == "sp9820a_12c20_2342A" ] ; then
        VENDOR_BIN=$PROJECT_DEV_PATH/modem_bins/Modem_TDS_2342A
    else
        VENDOR_BIN=$PROJECT_DEV_PATH/modem_bins/Modem_TDS
    fi
else
    #sp9820a_refh10
    VENDOR_BIN=$PROJECT_DEV_PATH/modem_bins
fi
if [ -n "$1" ] ; then
    release_version=$1
else
    release_version=ALIYUNOS-5.2.0-${TARGET_NAME}-$(date +%Y%m%d-%H%M)
fi

copy_image
#for secure_boot build, zip all images for signing by YunOS
if [ "$SEC_BOOT" = "true" ];then
    sign_images
    zip_images
else
    create_pac
fi

