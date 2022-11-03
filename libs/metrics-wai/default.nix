# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation, base, bytestring, containers, gitignoreSource
, hspec, hspec-discover, http-types, imports, lib, metrics-core
, servant, servant-multipart, string-conversions, text, wai
, wai-middleware-prometheus, wai-route, wai-routing
}:
mkDerivation {
  pname = "metrics-wai";
  version = "0.5.7";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    base bytestring containers http-types imports metrics-core servant
    servant-multipart string-conversions text wai
    wai-middleware-prometheus wai-route wai-routing
  ];
  testHaskellDepends = [
    base bytestring containers hspec http-types imports metrics-core
    servant servant-multipart string-conversions text wai
    wai-middleware-prometheus wai-route wai-routing
  ];
  testToolDepends = [ hspec-discover ];
  description = "Metrics WAI integration";
  license = lib.licenses.agpl3Only;
}
