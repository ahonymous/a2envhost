#!/usr/bin/env bash

home () {
    local my_work="$HOME/work/";
    local target_file="$HOME/etc/apache2/sites-available/$1.conf";
    local my_s_enabled="$HOME/etc/apache2/sites-enabled/$1.conf";

    if [[ -d $my_work && $(find $my_work"/"$1 -type d) ]]; then
        local default_domain_name="$1.local";
        local default_email="$(git config --global user.email)";
        local default_project_name="$1";
        local project_dir=$my_work$default_project_name

        cp "template.conf" $target_file;

        if [ ! -L $my_s_enabled ]; then
            ln -s $target_file $my_s_enabled;
        fi

        sed -i 's|{{DOMAIN_NAME}}|'$default_domain_name'|g' $target_file
        sed -i 's|{{ADMIN_EMAIL}}|'$default_email'|g' $target_file
        sed -i 's|{{PROJECT_DIR}}|'$project_dir'|g' $target_file
        sed -i 's|{{PROJECT_NAME}}|'$default_project_name'|g' $target_file

        if [[ ! $(grep $default_domain_name "/etc/hosts") ]]; then
            sudo sh -c "echo '127.0.0.1    $default_domain_name' >> /etc/hosts && service apache2 restart";
        fi
    fi
}

home $1;