#-------------------------------------------------------------------------------
# Eos Url
#-------------------------------------------------------------------------------
#set -Ux EOS_MAIN_URL https://eos.greymass.com
#set -Ux EOS_MAIN_URL https://api.eoslaomao.com
set -Ux EOS_MAIN_URL https://eos.api.eosnation.io
#set -Ux EOS_MAIN_URL https://eospush.tokenpocket.pro
set -Ux EOS_TEST_URL http://192.168.50.2:8888
set -Ux WAX_MAIN_URL https://wax.greymass.com
# set -Ux WAX_MAIN_URL https://wax.cryptolions.io
set -Ux WAX_TEST_URL https://waxtestnet.greymass.com
#-------------------------------------------------------------------------------
# Eos Function
#-------------------------------------------------------------------------------
function cimport
    cleos wallet import $argv
end

function cimportn
    cleos wallet import -n $argv
end

function ckey
    cleos create key --to-console
end

function clock
    cleos wallet lock_all
end

function cm
    cleos -u $EOS_MAIN_URL $argv
end

function cmabi
    cleos -u $EOS_MAIN_URL get abi $argv
end

function cmacc
    cleos -u $EOS_MAIN_URL get account $argv
end

function cmap -d "approve multisig in the eos PE"
    cleos -u $EOS_MAIN_URL multisig approve msig.defi $argv[1] '{"actor":"'$argv[2]'","permission":"active"}' -p cpu.defi -p $argv[2]
end

function cmcel -d "cancel multisign in the eos PE"
    cleos -u $EOS_MAIN_URL multisig cancel msig.defi $argv[1] msig.defi -p cpu.defi -p msig.defi
end

function cmcode
    cleos -u $EOS_MAIN_URL get code $argv
end

function cmexec -d "exec multisig in the eos PE"
    cleos -u $EOS_MAIN_URL multisig exec msig.defi $argv[1] -p cpu.defi -p msig.defi
end

function cminfo
    cleos -u $EOS_MAIN_URL get info
end

function cmnacc -d "new account in the eos PE"
    cleos -u $EOS_MAIN_URL system newaccount --stake-cpu "0.01 EOS" --stake-net "0.01 EOS" --buy-ram-kbytes 9 defi $argv[1] $argv[2] $argv[3] -p cpu.defi -p defi
end

function cmproxy -d "voteproducer proxy in the eos PE"
    cleos -u $EOS_MAIN_URL system voteproducer proxy $argv[1] $argv[2]
end

function cmpush
    cleos -u $EOS_MAIN_URL push action $argv
end

function cmtb
    cleos -u $EOS_MAIN_URL get table $argv
end

function cmunlock
    cleos wallet unlock -n cm --password
end

function cmvote -d "voteproducer in the eos PE"
    cleos -u $EOS_MAIN_URL push action eosio voteproducer '{"voter":"$argv[1]","proxy":"","producers":["$argv[2]"]}' -p cpu.defi -p $argv[1]
end

function ct
    cleos -u $EOS_TEST_URL $argv
end

function ctabi
    cleos -u $EOS_TEST_URL get abi $argv
end

function ctacc
    echo $EOS_TEST_URL
    echo $argv
    cleos -u $EOS_TEST_URL get account $argv
end

function ctcode
    cleos -u $EOS_TEST_URL get code $argv
end

function ctcpu -d "buy cpu in the eos testing environment"
    cleos -u $EOS_TEST_URL system delegatebw "$argv[1]" "$argv[2]" "$argv[3] EOS" "$argv[3] EOS"
end

function ctinfo
    cleos -u $EOS_TEST_URL get info
end

function ctnacc -d "new account in the eos testing environment"
    cleos -u $EOS_TEST_URL system newaccount --stake-cpu "10 EOS" --stake-net "10 EOS" --buy-ram-kbytes 9 eosio $argv[1] EOS8H9i7oX8gLNJwJ4oB23uqVK3vFtK7KTjX8Qj788RDL8vNv18VK -p cpu.defi -p eosio
end

function ctncon -d "new contracleos -u $EOS_TEST_URL in the eos testing environment"
    cleos -u $EOS_TEST_URL system newaccount --stake-cpu "10 EOS" --stake-net "10 EOS" --buy-ram-kbytes 9 eosio $argv[1] EOS7cuP3R3TB4Zwf84tUNH8tBfRTzb67xyDSGTqq9D9tP2qG4EEL4 -p cpu.defi -p eosio
end

function ctproxy -d "voteproducer proxy in the eos testing environment"
    cleos -u $EOS_TEST_URL system voteproducer proxy $argv[1] $argv[2]
end

function ctpush
    cleos -u $EOS_TEST_URL push action $argv
end

function ctram -d "buy ram in the eos testing environment"
    cleos -u $EOS_TEST_URL system buyram "$argv[1]" "$argv[2]" -k "$argv[3]" -p cpu.defi -p "$argv[1]"
end

function cttb
    cleos -u $EOS_TEST_URL get table $argv
end

function ctunlock
    cleos wallet unlock -n ct --password PW5JDC4CYFJU5c6Z1RF1AZtUTwhDsYxV5WWTcGVPTi2epMNuP6oer
end

function hardhat_abi
    npx hardhat export-abi $argv
end

function hardhat_account
    npx hardhat account
end

function hardhat_bsc
    npx hardhat deploy --network bsc
end
#https://speedy-nodes-nyc.moralis.io/adc559c1cf26887253941069/bsc/testnet
function hardhat_bsctest
    npx hardhat deploy --network bsctest
end

function hardhat_chain
    npx hardhat node --network hardhat --hostname 0.0.0.0 --fork https://eth-mainnet.alchemyapi.io/v2/wlIjDPGBuerlY0ZF6fYHYZnb-7VJTRJg
end

function hardhat_chainbsc
    npx hardhat node --network hardhat --hostname 0.0.0.0 --fork https://bsc-dataseed1.ninicoin.io/
end

function hardhat_chainbsctest
    npx hardhat node --network hardhat --hostname 0.0.0.0 --fork https://speedy-nodes-nyc.moralis.io/adc559c1cf26887253941069/bsc/testnet
end

function hardhat_deploy-script
    npx hardhat deploy --network hardhat --deploy-scripts
end

function hardhat_flatten
    npx waffle flatten
end

function hardhat_ganache
    npx hardhat deploy --network ganache
end

function hardhat_localhost
    npx hardhat deploy --network hardhat
end

function hardhat_mainnet
    npx hardhat deploy --network mainnet
end

function hardhat_rinkeby
    npx hardhat deploy --network rinkeby
end

function hardhat_script
    npx hardhat run --network hardhat $argv
end

function hardhat_size
    npx hardhat size-contracts
end

function hardhat_tracer-rinkeby
    npx hardhat trace --rpc https://rinkeby.infura.io/v3/745c6979172a4d3f97a086117d580373 --hash $argv
end

function hardhat_tracer
    npx hardhat trace --rpc http://127.0.0.1:8545 --hash $argv
end

function hardhat_verify
    npx hardhat etherscan-verify --network $argv
end

function startBal -d "bal.defi start"
    cleos -u $EOS_MAIN_URL push action bal.defi setstatus '{"status":"ok"}' -p cpu.defi -p admin.defi
end

function startBss -d "bss.defi start"
    cleos -u $EOS_MAIN_URL push action bss.defi setstatus '[0]' -p cpu.defi -p admin.defi
end

function startBssr -d "bssr.defi start"
    cleos -u $EOS_MAIN_URL push action bssr.defi setstatus '[0]' -p cpu.defi -p admin.defi
end

function startEosLend -d "lend.defi start"
    cleos -u $EOS_MAIN_URL push action lend.defi modifyconfig '{"key":"systemstate","val":0}' -p cpu.defi -p admin.defi
end

function startEosSwap -d "swap.defi start"
    cleos -u $EOS_MAIN_URL push action swap.defi updatestatus '[0]' -p cpu.defi -p admin.defi
end

function startUsn -d "danchorsmart start"
    cleos -u $EOS_MAIN_URL push action danchorsmart setstate '["maintain", 1]' -p cpu.defi -p admin.defi
end

function stopBal
    cleos -u $EOS_MAIN_URL push action bal.defi setstatus '{"status":"stop"}' -p cpu.defi -p admin.defi
end

function stopBss -d "bss.defi stop"
    cleos -u $EOS_MAIN_URL push action bss.defi setstatus '[1]' -p cpu.defi -p admin.defi
end

function stopBssr -d "bssr.defi 暂停，存单、提取系统暂停不能操作，复投不影响"
    cleos -u $EOS_MAIN_URL push action bssr.defi setstatus '[1]' -p cpu.defi -p admin.defi
end

function stopEosLend -d "lend.defi stop"
    cleos -u $EOS_MAIN_URL push action lend.defi modifyconfig '{"key":"systemstate","val":1}' -p cpu.defi -p admin.defi
end

function stopEosSwap -d "swap.defi stop"
    cleos -u $EOS_MAIN_URL push action swap.defi updatestatus '[1]' -p cpu.defi -p admin.defi
end

function stopUsn -d "danchorsmart stop"
    cleos -u $EOS_MAIN_URL push action danchorsmart setstate '["maintain", 0]' -p cpu.defi -p admin.defi
end

function toggle_cm -d "toggle main  url"
    if test $argv == 1
        set -Ux EOS_MAIN_URL https://eos.api.eosnation.io
    else if test $argv == 2
        set -Ux EOS_MAIN_URL https://eos.greymass.com
    else if test $argv == 3
        set -Ux EOS_MAIN_URL https://api.eoslaomao.com
    else
        set -Ux EOS_MAIN_URL https://eospush.tokenpocket.pro
    end
end

function withdrawBal -d "bal.defi 只允许提取"
    cleos -u $EOS_MAIN_URL push action bal.defi setstatus '{"status":"withdraw"}' -p cpu.defi -p admin.defi
end

function wm
    cleos -u $WAX_MAIN_URL $argv
end

function wmabi
    cleos -u $WAX_MAIN_URL get abi $argv
end

function wmacc
    cleos -u $WAX_MAIN_URL get account $argv
end

function wmap -d "approve multisig in the wax PE"
    cleos -u $WAX_MAIN_URL multisig approve msig.box $argv[1] '{"actor":"'$argv[2]'","permission":"active"}' -p cpu.box -p $argv[2]
end

function wmcel -d "cancel multisig in the wax PE"
    cleos -u $WAX_MAIN_URL multisig cancel msig.box $argv[1] msig.box -p cpu.box -p msig.box
end

function wmcode
    cleos -u $WAX_MAIN_URL get code $argv
end

function wmexec -d "exec multisig in the wax PE"
    cleos -u $WAX_MAIN_URL multisig exec msig.box $1 -p cpu.box -p msig.box
end

function wminfo
    cleos -u $WAX_MAIN_URL get info
end

function wmnacc -d "new account in the wax PE"
    cleos -u $WAX_MAIN_URL system newaccount --stake-cpu "0.01 WAX" --stake-net "0.01 WAX" --buy-ram-kbytes 9 box $argv[1] $argv[2] $argv[3] -p cpu.box -p box
end

function wmpush
    cleos -u $WAX_MAIN_URL push action --use-old-rpc --return-failure-trace false $argv
end

function wmtb
    cleos -u $WAX_MAIN_URL get table $argv
end

function wmunlock
    cleos wallet unlock -n wm --password
end

function wt
    cleos -u $WAX_TEST_URL $argv
end

function wtabi
    cleos -u $WAX_TEST_URL get abi $argv
end

function wtacc
    cleos -u $WAX_TEST_URL get account $argv
end

function wtcode
    cleos -u $WAX_TEST_URL get code $argv
end

function wtinfo
    cleos -u $WAX_TEST_URL get info $argv
end

function wtnacc -d "new account in the wax testing environment"
    cleos -u $WAX_TEST_URL system newaccount --stake-cpu "10 WAX" --stake-net "10 WAX" --buy-ram-kbytes 9 eosio $argv[1] $argv[2] -p cpu.box -p eosio
end

function wtpush
    cleos -u $WAX_TEST_URL push action $argv
end

function wttb
    cleos -u $WAX_TEST_URL get table
end

function wtunlock
    cleos wallet unlock -n wt --password PW5KhW9Yar3RK7Q4a1msLnwqnhRxCDYT6cfNrzrXZ7LTvRXaTRn7i
end
#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
function __ssh_agent_is_started -d "check if ssh agent is already started"
    if begin
            test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"
        end
        source $SSH_ENV >/dev/null
    end

    if test -z "$SSH_AGENT_PID"
        return 1
    end

    ssh-add -l >/dev/null 2>&1
    if test $status -eq 2
        return 1
    end
end

function __ssh_agent_start -d "start a new ssh agent"
    ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
    chmod 600 $SSH_ENV
    source $SSH_ENV >/dev/null
    ssh-add
end

if not test -d $HOME/.ssh
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
end

if test -d $HOME/.gnupg
    chmod 0700 $HOME/.gnupg
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

#-------------------------------------------------------------------------------
# Ghostty Shell Integration
#-------------------------------------------------------------------------------
# Ghostty supports auto-injection but Nix-darwin hard overwrites XDG_DATA_DIRS
# which make it so that we can't use the auto-injection. We have to source
# manually.
if set -q GHOSTTY_RESOURCES_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

#-------------------------------------------------------------------------------
# Programs
#-------------------------------------------------------------------------------
# Vim: We should move this somewhere else but it works for now
mkdir -p $HOME/.vim/{backup,swap,undo}

# Homebrew
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    set -q PATH; or set PATH ''
    set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
# Do not show any greeting
set --universal --erase fish_greeting
function fish_greeting
end
funcsave fish_greeting

# bobthefish theme
set -g theme_color_scheme dracula

# My color scheme
set -U fish_color_normal normal
set -U fish_color_command F8F8F2
set -U fish_color_quote F1FA8C
set -U fish_color_redirection 8BE9FD
set -U fish_color_end 50FA7B
set -U fish_color_error FF5555
set -U fish_color_param 5FFFFF
set -U fish_color_comment 6272A4
set -U fish_color_match --background=brblue
set -U fish_color_selection white --bold --background=brblack
set -U fish_color_search_match bryellow --background=brblack
set -U fish_color_history_current --bold
set -U fish_color_operator 00a6b2
set -U fish_color_escape 00a6b2
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_valid_path --underline
set -U fish_color_autosuggestion BD93F9
set -U fish_color_user brgreen
set -U fish_color_host normal
set -U fish_color_cancel -r
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D yellow
set -U fish_pager_color_prefix white --bold --underline
set -U fish_pager_color_progress brwhite --background=cyan

# Override the nix prompt for the theme so that we show a more concise prompt
function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = no -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns N ' '

    set_color normal
end

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
# Modify our path to include our Go binaries
contains $HOME/code/go/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/code/go/bin
contains $HOME/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/bin

# Exported variables
if isatty
    set -x GPG_TTY (tty)
end

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# Shortcut to setup a nix-shell with fish. This lets you do something like
# `fnix -p go` to get an environment with Go but use the fish shell along
# with it.
alias fnix "nix-shell --run fish"
