{
    chez,
    fetchurl,
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
  version = "0.46.1";

  src = fetchurl {
    url = "https://github.com/tizoc/shen-scheme/releases/download/v${final.version}/shen-scheme-v${final.version}-src.tar.gz";
    hash = "sha256-HTMjubr/CTc2//xn/yBDf1Oj7jeLQ9M3V/XJvbLThAs=";
  };

  strictDeps = true;
  enableParallelBuilding = true;
  dontStrip = true; # necessary to prevent runtime errors with chez

  nativeBuildInputs = [
    custom-chez
  ];
  buildInputs = [
    lz4
    zlib
  ] ++ lib.optional stdenv.isLinux libuuid;

  makeFlags = [
    "csbinpath=${custom-chez}/bin"
    "csboot=$(csbootpath)$(S)scheme.boot"
    "csbootpath=$(csdir)$(S)$(m)"
    "csdir=${custom-chez}/lib/csv${custom-chez.version}"
    "cskernel="
    "csversion=${custom-chez.version}"
    "prefix=$(out)"
    "psboot=$(csbootpath)$(S)petite.boot"
    "lz4="
    "zlib="
    "lz4dir=${lib.getLib lz4}/lib"
    "zlibdir=${lib.getLib zlib}/lib"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/shen-scheme" --version >/dev/null

    runHook postInstallCheck
  '';

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
