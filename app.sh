### ZLIB ###
_build_zlib() {
local VERSION="1.2.11"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.0.2e"
local FOLDER="openssl-${VERSION}"
local FILE="${FOLDER}.tar.gz"
#local URL="http://mirror.switch.ch/ftp/mirror/openssl/source/old/1.0.2/${FILE}"
local URL="https://www.openssl.org/source/old/1.0.2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
cp -vf "src/${FOLDER}-parallel-build.patch" "target/${FOLDER}/"
pushd "target/${FOLDER}"
patch -p1 -i "${FOLDER}-parallel-build.patch"
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/lib" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} \
  -Wa,--noexecstack -Wl,-z,noexecstack \
  no-asm
sed -i -e "s/-O3//g" Makefile
make
make install_sw
mkdir -p "${DEST}/libexec"
cp -vfa "${DEPS}/bin/openssl" "${DEST}/libexec/"
cp -vfa "${DEPS}/lib/libssl.so"* "${DEST}/lib/"
cp -vfa "${DEPS}/lib/libcrypto.so"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/engines" "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/pkgconfig" "${DEST}/lib/"
rm -vf "${DEPS}/lib/libcrypto.a" "${DEPS}/lib/libssl.a"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libcrypto.pc"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libssl.pc"
popd
}

### SQLITE3 ###
_build_sqlite3() {
local VERSION="3240000"
local FOLDER="sqlite-autoconf-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://www.sqlite.org/2018/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEST}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### Bacula ###
_build_bacula() {

local FOLDER="bacula"
pushd "target/${FOLDER}"
ac_cv_func_setpgrp_void=yes \
./configure \
  --host=${HOST} \
  --prefix="${DEST}" \
  --with-sqlite3="${DEPS}" \
  --with-logdir=${DEST}/logs 

#  --sbindir=${DEST}/bacula/sbin \
#  --sysconfdir=${DEST}/bacula/etc \
#  --with-pid-dir=${DEST}/bacula/var \
#  --with-subsys-dir=${DEST}/bacula/bin/working \
#  --with-working-dir=${DEST}/bacula/bin/working \

make
make install
popd
}

_build() {
  _build_zlib
  _build_openssl
  _build_sqlite3
  _build_bacula
  _package
}
