{
  description = "A Nix-flake-based C/C++ development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Create a function that imports nixpkgs with our config
      pkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

      # Create android composition using the configured pkgs
      androidComposition = (pkgs "x86_64-linux").androidenv.composeAndroidPackages {
        cmdLineToolsVersion = "13.0";
        toolsVersion = "26.1.1";
        platformToolsVersion = "34.0.4";
        buildToolsVersions = [ "34.0.0" ];
        includeEmulator = false;
        emulatorVersion = "30.3.4";
        platformVersions = [ "34" ];
        includeSources = false;
        includeSystemImages = false;
        systemImageTypes = [ "google_apis_playstore" ];
        abiVersions = [
          "armeabi-v7a"
          "arm64-v8a"
        ];
        cmakeVersions = [ "3.10.2" ];
        includeNDK = true;
        ndkVersion = "23.2.8568313";
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
      };

      ndkVersion = androidComposition.ndkVersions.head;

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = pkgs system;
          }
        );

    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              godot
              scons
              libqalculate
              jdk17
              pkg-config
              android-udev-rules
            ];
            shellHook = ''
              alias godot="godot4"
              export ANDROID_HOME="${androidComposition.androidsdk}/libexec/android-sdk";
              export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/23.2.8568313";
              export ANDROID_SDK_ROOT="$ANDROID_HOME";
              export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/34.0.0/aapt2";
            '';
          };
        }
      );
    };
}
