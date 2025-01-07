{
  description = "Sample SoPra dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"] (
      system: let
        overlays = [
          (self: super: {
            nodejs = super.nodejs_20;
            yarn = super.yarn.override {
              nodejs = super.nodejs_20;
            };
          })
        ];

        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = overlays;
        };

        pkgsStable = import nixpkgs-stable {
          inherit system;
        };

        nativeBuildInputs = with pkgs;
          [
            nodejs
            yarn
            deno # Add Deno runtime for demo
            watchman
          ]
          ++ lib.optionals stdenv.isDarwin [
            xcodes
          ]
          ++ lib.optionals (system == "aarch64-linux") [
            qemu
          ];
      in {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs;

          JAVA_HOME = pkgs.jdk21.home;

          shellHook = ''
            export HOST_PROJECT_PATH="$(pwd)"
            export COMPOSE_PROJECT_NAME=samplesopra
            export JAVA_HOME=${pkgs.jdk21.home}
            export PATH=$JAVA_HOME/bin:$PATH
            XCODE_VERSION_OLD="15.3"
            XCODE_VERSION="16.1"
            XCODE_BUILD_OLD="15E204a" 
            XCODE_BUILD="16B40"
            if [[ $(uname) == "Darwin" ]] && [ -z "$CI" ]; then
              if ! (xcodes installed | grep "$XCODE_VERSION ($XCODE_BUILD) (Selected)" -q || xcodes installed | grep "$XCODE_VERSION_OLD ($XCODE_BUILD_OLD) (Selected)" -q); then
                echo -e "\e[1;33m================================================\e[0m"
                echo -e "\e[1;33mIf you wish to code in XCode, please install $XCODE_VERSION or $XCODE_VERSION_OLD\e[0m"
                echo -e "\e[1;33mYou can install it with \e[0m\e[1;32mxcodes install $XCODE_VERSION\e[0m\e[1;33m and select it with \e[0m\e[1;32mxcodes select $XCODE_VERSION\e[0m\e[1;33m\e[0m"
                echo -e "\e[1;33m================================================\e[0m"
              fi
            fi

            if [[ $(uname) == "Darwin" ]]; then
              echo "export NODE_BINARY=\"$(which node)\"" > .xcode.env.local
            fi

            export PATH=$(echo $PATH | tr ':' '\n' | grep -v clang | paste -sd ':' -)

            if [[ -f package.json && ( ! -d node_modules || -z "$(ls -A node_modules)" ) ]]; then
              echo "Running npm install to install dependencies..."
              npm install || echo -e "\e[1;31mFailed to run npm install. Please check your package.json.\e[0m"
            fi
          '';
        };
      }
    );
}
