{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  nodejs_22,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeBinaryWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-headless";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    rev = finalAttrs.version;
    hash = "sha256-ue2M9maFyvabGH9qTDOpAJS4OPwCikpAMYm/M/XRGKo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-xkQHk86msMBs7FXqJNoKdSzB0IxyqfFf6rBnPom4YxU=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    python3
    nodejs_22
    pnpm
    pnpmConfigHook
    makeBinaryWrapper
  ];

  # Rebuild native modules (better-sqlite3)
  buildPhase = ''
    runHook preBuild
    
    export npm_config_build_from_source=true
    export npm_config_nodedir=${nodejs_22}
    
    echo "Building better-sqlite3 native module..."
    pushd node_modules/.pnpm/better-sqlite3@12.11.1/node_modules/better-sqlite3
    ${nodejs_22}/bin/npm run build-release
    popd
    
    # Verify the .node file was created
    ls -la node_modules/.pnpm/better-sqlite3@12.11.1/node_modules/better-sqlite3/build/Release/ || true
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/obsidian-headless
    cp -r . $out/lib/node_modules/obsidian-headless

    mkdir -p $out/bin
    makeBinaryWrapper ${nodejs_22}/bin/node $out/bin/ob \
      --add-flags "$out/lib/node_modules/obsidian-headless/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Headless client for Obsidian Sync and Publish. Sync your vaults from the command line";
    homepage = "https://github.com/obsidianmd/obsidian-headless";
    changelog = "https://github.com/obsidianmd/obsidian-headless/blob/master/CHANGELOG.md";
    license = lib.licenses.unfree;
    maintainers = [ ];
    mainProgram = "ob";
    platforms = lib.platforms.unix;
  };
})
