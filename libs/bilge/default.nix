# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, ansi-terminal
, base
, bytestring
, case-insensitive
, cookie
, errors
, exceptions
, gitignoreSource
, http-client
, http-types
, imports
, lens
, lib
, monad-control
, mtl
, text
, tinylog
, transformers-base
, types-common
, uri-bytestring
, wai
, wai-extra
, wire-otel
}:
mkDerivation {
  pname = "bilge";
  version = "0.22.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    ansi-terminal
    base
    bytestring
    case-insensitive
    cookie
    errors
    exceptions
    http-client
    http-types
    imports
    lens
    monad-control
    mtl
    text
    tinylog
    transformers-base
    types-common
    uri-bytestring
    wai
    wai-extra
    wire-otel
  ];
  description = "Library for composing HTTP requests";
  license = lib.licenses.agpl3Only;
}
