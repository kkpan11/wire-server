# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation, aeson, async, base, bilge, bytestring
, bytestring-conversion, data-timeout, exceptions, gitignoreSource
, http-client, http-types, imports, lib, random, tasty-hunit
, types-common, websockets, wire-api
}:
mkDerivation {
  pname = "tasty-cannon";
  version = "0.4.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson async base bilge bytestring bytestring-conversion
    data-timeout exceptions http-client http-types imports random
    tasty-hunit types-common websockets wire-api
  ];
  description = "Cannon Integration Testing Utilities";
  license = lib.licenses.agpl3Only;
}
