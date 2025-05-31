{
    chez,
    lib,
    libuuid,
    stdenv,
}:
stdenv.mkDerivation (final: {
  pname = "shen-scheme";
  version = "0.40";

  src = builtins.fetchTarball {
    url = "https://github.com/tizoc/shen-scheme/releases/download/v${final.version}/shen-scheme-v${final.version}-src.tar.gz";
    sha256 = "sha256:1fn8i63xwj99l26dfr0d1flykci14d75c3ycsbppc6v6yih9agmw";
  };

  nativeBuildInputs = [ chez ];
  buildInputs = lib.optional stdenv.isLinux libuuid;
  dontStrip = true; # necessary to prevent runtime errors with chez

  makeFlags = [
    "CFLAGS=-O3"
    "csbinpath=${chez}/bin"
    "csboot=$(csbootpath)$(S)scheme.boot"
    "csbootpath=$(csdir)$(S)$(m)"
    "csdir=${chez}/lib/csv${chez.version}"
    "cskernel="
    "csversion=${chez.version}"
    "lz4dirname="
    "prefix=$(out)"
    "psboot=$(csbootpath)$(S)petite.boot"
    "zlibdirname="
  ];

  meta = {
    homepage = "https://github.com/tizoc/shen-scheme";
    description = "A Scheme port of the Shen language";
    changelog = "https://github.com/tizoc/shen-scheme/blob/master/CHANGELOG.md";
    platforms = chez.meta.platforms;
    maintainers = with lib.maintainers; [ hakujin ];
    license = lib.licenses.bsd3;
    mainProgram = "shen-scheme";
  };
})
