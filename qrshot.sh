#!/bin/bash

# VARIABLES
if [[ $TMP == "" ]]; then
    TMP=/tmp
fi
PROCESSED=$TMP/scan-output.png
OCR_TMP=$TMP/ocr-output
DATE=$(date "+%F-%H-%M-%S")
CLIP=$(xclip -o -selection clipboard)
DIR=$(pwd)

case $(ps -o stat= -p $$) in
  *+*) FG=1 ;;
  *) FG=0 ;;
esac


# PROCESS IMAGE TYPE 1
process_img_type1 () {
    convert $INPUT -fill white -fuzz 10% +opaque "#000000" $PROCESSED
}

# PROCESS IMAGE TYPE 2
process_img_type2 () {
    convert $INPUT +dither  -colors 2  -colorspace gray -normalize $PROCESSED
}

# SCAN FUNCTION
scan_qr () {
    process_img_type1
    OUTPUT=$(echo $(zbarimg -q $PROCESSED) | sed 's/^.*Code://')
    if [[ $OUTPUT == "" ]]; then
        process_img_type2
        OUTPUT=$(echo $(zbarimg -q $PROCESSED) | sed 's/^.*Code://')
        if [[ $OUTPUT == "" ]]; then
            OUTPUT="Unable to read QR code"
            if [[ $FG == 0 ]]; then
                notify-send "QR Code Output:" "$OUTPUT" --icon=dialog-information
            fi
        fi
    fi
}

image_ocr () {
    PROCESSED=$INPUT
    tesseract $PROCESSED $OCR_TMP
    OUTPUT=$(cat $OCR_TMP.txt)
}

if [[ ! "$1" || "$1" == "grab" ]]; then

    INPUT=$TMP/scan-input.png
    echo Use mouse select an area on screen, then press enter, to decode QR.
    echo ""

    spectacle -b -r -n -o $INPUT
    scan_qr
    echo $OUTPUT
    if [[ $FG == 0 ]]; then
        notify-send "QR Code Output:" "$OUTPUT" --icon=dialog-information
    fi
    if [[ "$2" == "clip" ]]; then
        echo "Saving to Clipboard..."
        echo $OUTPUT | xclip -selection clipboard -i
    elif [[ "$2" == "open" ]]; then
        if [[ "$OUTPUT" == "https"* || "$OUTPUT" == "http"* ]]; then
            echo "Opening Link..."
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Output:' "Opening $OUTPUT" --icon=dialog-information
            fi
            xdg-open $OUTPUT
        else
            echo "QR scanned did not contain a URL"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Error:' "QR scanned did not contain a URL" --icon=dialog-information
            fi
        fi
    fi
elif [[ "$1" == "read" ]]; then
    if [[ "$2" == "open" ]]; then
        INPUT=$3
        scan_qr
        if [[ "$OUTPUT" == "https"* || "$OUTPUT" == "http"* ]]; then
            echo "Opening Link..."
            xdg-open $OUTPUT
        else
            echo "QR scanned did not contain a URL"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Error:' "QR scanned did not contain a URL" --icon=dialog-information
            fi
        fi
    elif [[ "$2" == "clip" ]]; then
        INPUT=$3
        scan_qr
        echo $OUTPUT | xclip -selection clipboard -i
        if [[ $FG == 0 ]]; then
            notify-send 'QR Code Output:' "QR Copied to Clipboard" --icon=dialog-information
        fi
    else
        INPUT=$2
        scan_qr
        echo $OUTPUT
    fi
elif [[ "$1" == "gen" ]]; then
    if [[ "$2" == "img" ]]; then
        if [[ ! "$4" ]]; then
            qrencode -m 2 -t PNG -o "$DATE-qr.png" "$3"
            echo "QR code saved to: $DIR/$DATE-qr.png"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Output:' "QR code saved to: $DIR/$DATE-qr.png" --icon=dialog-information
            fi
        else
            cd $4
            qrencode -m 2 -t PNG -o "$DATE-qr.png" "$3"
            echo "QR code saved to: $4/$DATE-qr.png"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Output:' "QR code saved to: $4/$DATE-qr.png" --icon=dialog-information
            fi
        fi
    elif [[ "$2" == "clip" ]]; then
        qrencode -m 2 -t PNG -o "$PROCESSED" "$3"
        xclip -selection clipboard -t image/png -i < $PROCESSED
        echo "Copied QR code with string '$3' to clipboard"
        if [[ $FG == 0 ]]; then
            notify-send 'QR Code Output:' "Copied QR code with string '$3' to clipboard" --icon=dialog-information
        fi
    else
        qrencode -m 2 -t ANSIUTF8 "$2"
    fi
elif [[ "$1" == "clip" ]]; then
    if [[ "$2" == "img" ]]; then
        if [[ ! "$3" ]]; then
            qrencode -m 2 -t PNG -o "$DATE-qr.png" "$CLIP"
            echo "QR code saved to: $DIR/$DATE-qr.png"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Output:' "QR code saved to: $DIR/$DATE-qr.png" --icon=dialog-information
            fi
        else
            cd $3
            qrencode -m 2 -t PNG -o "$DATE-qr.png" "$CLIP"
            echo "QR code saved to: $3/$DATE-qr.png"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Output:' "QR code saved to: $3/$DATE-qr.png" --icon=dialog-information
            fi
        fi
    elif [[ "$2" == "copy" ]]; then
        qrencode -m 2 -t PNG -o "$PROCESSED" "$CLIP"
        xclip -selection clipboard -t image/png -i < $PROCESSED
        echo "Copied QR code with string '$CLIP' to clipboard"
        if [[ $FG == 0 ]]; then
            notify-send 'QR Code Output:' "Copied QR code with string '$CLIP' to clipboard" --icon=dialog-information
        fi
    else
        qrencode -m 2 -t ANSIUTF8 "$CLIP"
    fi
elif [[ "$1" == "ocr" ]]; then
    INPUT=$TMP/scan-input.png
    spectacle -b -r -n -o $INPUT
    image_ocr

    if [[ "$2" == "open" ]]; then
        if [[ "$OUTPUT" == "https"* || "$OUTPUT" == "http"* ]]; then
            echo "Opening Link..."
            xdg-open $OUTPUT
        else
            echo "QR scanned did not contain a URL"
            if [[ $FG == 0 ]]; then
                notify-send 'QR Code Error:' "QR scanned did not contain a URL" --icon=dialog-information
            fi
        fi
    elif [[ "$2" == "clip" ]]; then
        echo $OUTPUT | xclip -selection clipboard -i
        if [[ $FG == 0 ]]; then
            notify-send 'OCR Output:' "Text Copied to Clipboard" --icon=dialog-information
        fi
    else
        echo $OUTPUT
        if [[ $FG == 0 ]]; then
            notify-send "OCR Output:" "$OUTPUT" --icon=dialog-information
        fi
    fi
else
    echo "QRShot QR code scanner / creator"
    echo "Usage:"
    echo "qrshot grab                           - opens screenshot dialog and scans qr code"
    echo "       grab open                      - opens screenshot dialog and scans qr code, opening any URLs"
    echo "       grab clip                      - opens screenshot dialog and scans qr code, copying it to clipboard"
    echo "qrshot read <location>                - scans qr code from file"
    echo "       read open <location>           - scans qr code from file, opening any URLs"
    echo "       read clip <location>           - scans qr code from file, copying it to clipboard"
    echo "qrshot gen <string>                   - generates a qr code from a string"
    echo "       gen img <string> <location>    - generates a qr code from a string, saving it as a png in the current directory, or to specified location"
    echo "       gen clip <string>              - generates a qr code from a string, saving it as a png and copying it to the clipboard"
    echo "qrshot clip                           - generates a qr code from the clipboard"
    echo "       clip img <location>            - generates a qr code from the clipboard, and saves the png image to the current directory, or the specified location"
    echo "       clip copy                      - generates a qr code from the clipboard, saving it as a png and copying it to the clipboard"
    echo "qrshot ocr                            - opens screenshot dialog and scans text"
    echo "qrshot ocr open                       - opens screenshot dialog and scans text, opening any URLs"
    echo "qrshot ocr clip                       - opens screenshot dialog and scans text, copying it to clipboard"
fi
