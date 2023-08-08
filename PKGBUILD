# Maintainer: Moxvallix <moxvallix gmail>

pkgname=qrshot
pkgver=r7.8c8af42
pkgrel=1
pkgdesc="QRShot is a simple script to decode and create QR codes. Scan QR codes directly from your screen, generate QR codes from your clipboard, or read a QR code from a file."
arch=("any")

url="https://github.com/moxvallix/qrshot"
license=("GPL3")

depends=("imagemagick" "spectacle" "zbar" "qrencode" "xclip" "libnotify" "tesseract")
makedepends=("git")

source=(
    "${pkgname}::git+https://github.com/moxvallix/${pkgname}.git"
)
sha512sums=(
    "SKIP"
)
pkgver() {
  cd "${pkgname}"
  printf "r%s.%s\n" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd "${pkgname}"

    install -m755 -D "qrshot.sh" "$pkgdir/usr/bin/qrshot"
    install -m644 -D "LICENSE.txt" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
