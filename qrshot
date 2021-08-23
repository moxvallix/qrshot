#!/bin/bash

# VARIABLES
PROCESSED=/tmp/scan-output.png
DATE=$(date "+%F-%H-%M-%S")
CLIP=$(xclip -o -selection clipboard)

# SCAN FUNCTION
scan_qr () {
    convert $INPUT +dither  -colors 2  -colorspace gray -normalize $PROCESSED
    OUTPUT=$(echo $(zbarimg -q $PROCESSED) | sed 's/^.*Code://')
}

if [[ ! "$1" || "$1" == "grab" ]]; then

    INPUT=/tmp/scan-input.png
    echo Use mouse select an area on screen, then press enter, to decode QR.
    echo ""

    spectacle -b -r -n -o $INPUT
    scan_qr
    echo $OUTPUT
    if [[ "$2" == "clip" ]]; then
        echo "Saving to Clipboard..."
        echo $OUTPUT | xclip -selection clipboard -i
    elif [[ "$2" == "open" ]]; then
        if [[ "$OUTPUT" == "https"* || "$OUTPUT" == "http"* ]]; then
            echo "Opening Link..."
            xdg-open $OUTPUT
        else
            echo "QR scanned did not contain a URL"
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
        fi
    elif [[ "$2" == "clip" ]]; then
        INPUT=$3
        scan_qr
        echo $OUTPUT | xclip -selection clipboard -i
    else
        INPUT=$2
        scan_qr
        echo $OUTPUT
    fi
elif [[ "$1" == "gen" ]]; then
    if [[ "$2" == "img" ]]; then
        if [[ ! "$3" ]]; then
            qrencode -m 2 -t PNG -o "~/Pictures/$DATE-qr.png" "$3"
            echo "QR code saved to: ~/Pictures/$DATE-qr.png"
        else
            qrencode -m 2 -t PNG -o "$2/$DATE-qr.png" "$3"
            echo "QR code saved to: $2/$DATE-qr.png"
        fi
    elif [[ "$2" == "clip" ]]; then
        qrencode -m 2 -t PNG -o "$PROCESSED" "$3"
        echo $PROCESSED | xclip -selection clipboard -i
    else
        qrencode -m 2 -t ANSIUTF8 "$2"
    fi
elif [[ "$1" == "clip" ]]; then
    if [[ "$2" == "img" ]]; then
        if [[ ! "$3" ]]; then
            qrencode -m 2 -t PNG -o "~/Pictures/$DATE-qr.png" "$CLIP"
            echo "QR code saved to: ~/Pictures/$DATE-qr.png"
        else
            qrencode -m 2 -t PNG -o "$3/$DATE-qr.png" "$CLIP"
            echo "QR code saved to: $3/$DATE-qr.png"
        fi
    elif [[ "$2" == "copy" ]]; then
        qrencode -m 2 -t PNG -o "$PROCESSED" "$CLIP"
        echo $PROCESSED | xclip -selection clipboard -i
    else
        qrencode -m 2 -t ANSIUTF8 "$CLIP"
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
    echo "       gen img <string> <location>    - generates a qr code from a string, saving it as a png in ~/Pictures, or to specified location"
    echo "       gen clip <string>              - generates a qr code from a string, saving it as a png and copying it to the clipboard"
    echo "qrshot clip                           - generates a qr code from the clipboard"
    echo "       clip img <location>            - generates a qr code from the clipboard, and saves the png image to ~/Pictures, or the specified location"
    echo "       clip copy                      - generates a qr code from the clipboard, saving it as a png and copying it to the clipboard"
fi
