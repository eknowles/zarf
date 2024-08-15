#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

add_yaml_extensions() {
  local src=$1
  local dst=$2

  jq '
    def addPatternProperties:
      . +
      if has("properties") then
        {"patternProperties": {"^x-": {}}}
      else
        {}
      end;

    walk(if type == "object" then addPatternProperties else . end)
  ' "$src" > "$dst"
}

go run "$SCRIPT_DIR/main.go" v1alpha1 > "zarf_package_v1alpha1.schema.json"
go run "$SCRIPT_DIR/main.go" v1beta1 > "zarf_package_v1beta1.schema.json"

add_yaml_extensions "zarf_package_v1alpha1.schema.json" "$SCRIPT_DIR/../../zarf.schema.json"
add_yaml_extensions "zarf_package_v1alpha1.schema.json" "$SCRIPT_DIR/../../schema/zarf_package_v1alpha1.schema.json"
add_yaml_extensions "zarf_package_v1beta1.schema.json" "$SCRIPT_DIR/../../schema/zarf_package_v1beta1.schema.json"

rm zarf_package_v1alpha1.schema.json
rm zarf_package_v1beta1.schema.json