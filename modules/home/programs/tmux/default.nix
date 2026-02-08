{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
    wl-clipboard # Wayland clipboard
    xclip # X11 clipboard (fallback)
  ];
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    extraConfig = ''
      # Reduce escape-time to fix delay when pressing Escape key
      set -sg escape-time 10

      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # reload config
      bind r source-file ~/.tmux.conf

      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # optional: Vim-style pane navigation without prefix
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # Enable mouse control (clickable windows, panes, resizable panes)
      set -g mouse on

      # DESIGN TWEAKS

      # don't do anything when a 'bell' rings
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # clock mode
      setw -g clock-mode-colour yellow

      # copy mode
      setw -g mode-style 'fg=black bg=red bold'

      # panes
      set -g pane-border-style 'fg=red'
      set -g pane-active-border-style 'fg=yellow'

      # statusbar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=red'

      set -g status-left '''
      set -g status-left-length 10

      set -g status-right-style 'fg=black bg=yellow'
      set -g status-right '%Y-%m-%d %H:%M '
      set -g status-right-length 50

      setw -g window-status-current-style 'fg=black bg=red'
      setw -g window-status-current-format ' #I #W #F '

      setw -g window-status-style 'fg=red bg=black'
      setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '

      setw -g window-status-bell-style 'fg=yellow bg=red bold'

      # messages
      set -g message-style 'fg=yellow bg=red bold'

      # ============================================
      # Clipboard Integration
      # ============================================
      # Enable clipboard passthrough
      set -g set-clipboard on

      # Use vi keys in copy mode
      setw -g mode-keys vi

      # Configure copy mode for system clipboard (auto-detect Wayland/X11)
      # Enter copy mode: Prefix + [
      # Start selection: v 
      # Copy to clipboard: y 
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'if command -v wl-copy >/dev/null 2>&1; then wl-copy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; elif command -v xsel >/dev/null 2>&1; then xsel --clipboard --input; fi' \; display-message "Copied to clipboard"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'if command -v wl-copy >/dev/null 2>&1; then wl-copy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; elif command -v xsel >/dev/null 2>&1; then xsel --clipboard --input; fi' \; display-message "Copied to clipboard"

      # Mouse selection copies to clipboard
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'if command -v wl-copy >/dev/null 2>&1; then wl-copy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; elif command -v xsel >/dev/null 2>&1; then xsel --clipboard --input; fi'
    '';
    plugins = with pkgs.tmuxPlugins; [
      yank
    ];
  };
}
