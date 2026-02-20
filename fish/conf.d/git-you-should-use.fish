# "You should use" — ZSH-style: suggest your Fish abbreviations (e.g. gst), not git config aliases (git st).
# Based on: https://github.com/MichaelAquilina/zsh-you-should-use
#
# ZSH plugin checks (1) shell aliases → "gst" for "git status", (2) git config aliases → "git st".
# We only do (1): we suggest the Fish abbr/alias name (gst), never "git st".
#
# Define ZSH-style git abbreviations below so we suggest gst, gco, gl, etc. when you type the full command.
# Add or remove to match your style.

if not abbr -q gst
    abbr -a gst 'git status'
end
if not abbr -q gco
    abbr -a gco 'git checkout'
end
if not abbr -q gl
    abbr -a gl 'git pull'
end
if not abbr -q gp
    abbr -a gp 'git push'
end
if not abbr -q gd
    abbr -a gd 'git diff'
end
if not abbr -q gds
    abbr -a gds 'git diff --staged'
end
if not abbr -q gc
    abbr -a gc 'git commit'
end
if not abbr -q gca
    abbr -a gca 'git commit -a'
end
if not abbr -q gb
    abbr -a gb 'git branch'
end
if not abbr -q gba
    abbr -a gba 'git branch -a'
end
if not abbr -q glg
    abbr -a glg 'git log --oneline --graph'
end
if not abbr -q glo
    abbr -a glo 'git log --oneline'
end
if not abbr -q gr
    abbr -a gr 'git remote'
end
if not abbr -q ga
    abbr -a ga 'git add'
end
if not abbr -q gap
    abbr -a gap 'git add -p'
end
if not abbr -q grb
    abbr -a grb 'git rebase'
end
if not abbr -q gsw
    abbr -a gsw 'git switch'
end
if not abbr -q gfr
    abbr -a gfr 'git fetch --all --prune'
end

# ─── Plugin settings ─────────────────────────────────────────────────────
set -q GIT_YSU_MESSAGE_POSITION || set -gx GIT_YSU_MESSAGE_POSITION "after"
set -q GIT_YSU_DISABLED || set -gx GIT_YSU_DISABLED 0

function _git_ysu_message
    set -l bold (set_color -o)
    set -l yellow (set_color yellow)
    set -l purple (set_color magenta)
    set -l normal (set_color normal)
    if set -q GIT_YSU_MESSAGE_FORMAT
        printf "%s\n" (string replace "%alias_type" "alias" \
            (string replace "%command" "$argv[1]" \
            (string replace "%alias" "$argv[2]" -- $GIT_YSU_MESSAGE_FORMAT)))
    else
        echo -s $bold $yellow "Found existing alias for " $purple "\"$argv[1]\"" $yellow ". You should use: " $purple "\"$argv[2]\"" $normal
    end
end

# Parse one line of "abbr --show" (e.g. "abbr -a -- gst 'git status'") → name, expansion
function _git_ysu_parse_abbr_line
    set -l line "$argv[1]"
    set -l parts (string split "'" "$line")
    if test (count $parts) -lt 2
        return 1
    end
    set -l expansion (string trim "$parts[2]")
    set -l left (string trim "$parts[1]")
    # left is "abbr -a -- gst" or "abbr -a gst" → last word is name
    set -l tokens (string split " " "$left")
    set -l name $tokens[-1]
    echo "$name"
    echo "$expansion"
end

function _git_ysu_check
    set -l typed (string trim "$argv[1]")
    if test -z "$typed" || test "$GIT_YSU_DISABLED" -eq 1
        return
    end
    if string match -q "sudo *" "$typed"
        return
    end

    abbr --show 2>/dev/null | while read -l line
        set -l parsed (_git_ysu_parse_abbr_line "$line")
        if test (count $parsed) -lt 2
            continue
        end
        set -l name $parsed[1]
        set -l expansion $parsed[2]
        if test -z "$expansion"
            continue
        end
        # Match: typed equals expansion or typed starts with "expansion "
        if test "$typed" = "$expansion"
            _git_ysu_message "$typed" "$name"
            return
        end
        if string match -q "$expansion *" "$typed"
            set -l rest (string sub -s (math (string length $expansion) + 2) "$typed")
            _git_ysu_message "$typed" "$name $rest"
            return
        end
    end
end

function _git_ysu_preexec --on-event fish_preexec
    set -e _git_ysu_last_cmd
    set -l cmd (string trim "$argv[1]")
    if test "$GIT_YSU_DISABLED" -eq 1
        return
    end
    if test "$GIT_YSU_MESSAGE_POSITION" = "before"
        _git_ysu_check "$cmd"
    else
        set -gx _git_ysu_last_cmd "$cmd"
    end
end

function _git_ysu_postexec --on-event fish_postexec
    if test "$GIT_YSU_MESSAGE_POSITION" = "after" && set -q _git_ysu_last_cmd
        _git_ysu_check "$_git_ysu_last_cmd"
        set -e _git_ysu_last_cmd
    end
end
