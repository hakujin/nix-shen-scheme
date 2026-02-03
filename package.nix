{
    chez,
    lib,
    libuuid,
    lz4,
    stdenv,
    zlib,
}:
# necessary to match the makefile's expectations for pre-built chez and prevent
# linker errors for ncurses and libiconv
let custom-chez = chez.overrideAttrs (_: prev: {
  configureFlags = prev.configureFlags ++ [
    "--disable-curses"
    "--disable-iconv"
    "--disable-x11"
  ];
});
in stdenv.mkDerivation (final: {
  pname = "shen-scheme";
  version = "0.42";

  src = builtins.fetchTarball {
    url = "https://github.com/tizoc/shen-scheme/releases/download/v${final.version}/shen-scheme-v${final.version}-src.tar.gz";
    sha256 = "sha256:1nk9fwm04v978s0sck9ym029vk7hl80wp6yi7imczzs7jjhl5sm0";
  };

  nativeBuildInputs = [ custom-chez lz4 zlib ];
  buildInputs = lib.optional stdenv.isLinux libuuid;
  dontStrip = true; # necessary to prevent runtime errors with chez
  NIX_CFLAGS_COMPILE = "-O3";

  makeFlags = [
    "csbinpath=${custom-chez}/bin"
    "csboot=$(csbootpath)$(S)scheme.boot"
    "csbootpath=$(csdir)$(S)$(m)"
    "csdir=${custom-chez}/lib/csv${custom-chez.version}"
    "cskernel="
    "csversion=${custom-chez.version}"
    "lz4dirname="
    "prefix=$(out)"
    "psboot=$(csbootpath)$(S)petite.boot"
    "zlibdirname="
  ];

  meta = {
    homepage = "https://github.com/tizoc/shen-scheme";
    description = "A Scheme port of the Shen language";
    changelog = "https://github.com/tizoc/shen-scheme/blob/master/CHANGELOG.md";
    platforms = custom-chez.meta.platforms;
    maintainers = with lib.maintainers; [ hakujin ];
    license = lib.licenses.bsd3;
    mainProgram = "shen-scheme";
  };
})
