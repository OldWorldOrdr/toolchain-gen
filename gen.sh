#!/bin/sh
usage() {
  printf "Usage: %s <tripple>\n" "$0"
  printf "Example: %s x86_64-unknown-freebsd13.1\n" "$0"
  printf "Example: %s powerpc-unknown-openbsd7.2\n" "$0"
  exit 0
}

case "$1" in
  *--help*)
    usage
  ;;
esac

if [ -z "$1" ]; then
  usage
fi

mkdir toolchain && cd toolchain || exit 1
mkdir bin && cd bin || exit 1

for i in addr2line ar dwp nm objcopy objdump ranlib readelf size strings strip; do
  printf "#!/bin/sh\n" > "$1-$i"
  printf "exec llvm-%s \"\$@\"\n" "$i" >> "$1-$i"
  chmod +x "$1-$i"
done

printf "#!/bin/sh\n" > "$1-ld"
printf "exec ld.lld \"\$@\"\n" >> "$1-ld"
chmod +x "$1-ld"

printf "#!/bin/sh\n" > "$1-clang"
printf "exec clang --target=%s --sysroot=\"\${0%%/*}/../sysroot\" \"\$@\"\n" "$1" >> "$1-clang"
chmod +x "$1-clang"

printf "#!/bin/sh\n" > "$1-clang++"
printf "exec clang++ --target=%s --sysroot=\"\${0%%/*}/../sysroot\" \"\$@\"\n" "$1" >> "$1-clang++"
chmod +x "$1-clang++"

ln -s "$1-clang" "$1-gcc"
ln -s "$1-clang++" "$1-g++"
ln -s "$1-clang" "$1-cc"
ln -s "$1-clang++" "$1-c++"

cd .. || exit 1
mkdir sysroot && cd sysroot || exit 1
cd .. || exit 1
cd .. || exit 1

printf "Script done, now you just need to populate the sysroot directory with the appropriate files for your target.\n"
printf "Dont forget to add the toolchain/bin directory to your PATH.\n"
