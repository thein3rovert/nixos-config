{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
     vscode                  # Visual Studio Code (IDE)
  ];
}
