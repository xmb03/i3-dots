#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# uv
export PATH="/home/xmb03/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/xmb03/.lmstudio/bin"
# End of LM Studio CLI section


# opencode
export PATH=/home/xmb03/.opencode/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
