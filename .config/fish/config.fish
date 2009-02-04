set -x PATH /home/steffoz /bin /usr/bin/ /usr/local/bin /usr/sbin /sbin

function fish_prompt --description "Write out the prompt"
        set -l my_user_name steffoz
        set -l my_host_name myhost

        if not set -q __fish_prompt_user
                set -g __fish_prompt_user "$USER "
                if test $__fish_prompt_user = "$my_user_name "
                        set -g __fish_prompt_user ""
                else
                        if test $__fish_prompt_user = "root "
                                set -g __fish_prompt_user (set_color red)"root "
                        end
                end
        end

        if not set -q __fish_prompt_hostname
                set -g __fish_prompt_hostname @(hostname)
                if test $__fish_prompt_hostname = "@$my_host_name"
                        set -g __fish_prompt_hostname ""
                end
        end

        printf '%s%s%s%s%s> \n' $__fish_prompt_user $__fish_prompt_hostname (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

