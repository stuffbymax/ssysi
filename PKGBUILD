# Maintainer: Your Name <your.email@example.com>
pkgname=ssysi
pkgver=1.0.0
pkgrel=1
pkgdesc="A lightweight system information tool written in Bash"
arch=('any')
url="https://github.com/stuffbymax/ssysi"
license=('MIT')
depends=('bash')
source=("https://raw.githubusercontent.com/stuffbymax/ssysi/main/ssysi.sh")
sha256sums=('SKIP')

package() {
    install -Dm755 "$srcdir/ssysi.sh" "$pkgdir/usr/bin/ssysi"
}
