#!/usr/bin/env bash

my_work="$HOME/work/";
function home () {
    local target_file="$HOME/etc/apache2/sites-available/$proj.conf";
    local my_s_enabled="$HOME/etc/apache2/sites-enabled/$proj.conf";

    if [[ -d $my_work && $(find $my_work"/"$proj -type d) ]]; then
        local default_domain_name="$proj.local";
        local default_email="$(git config --global user.email)";
        local default_project_name=$proj;
        local project_dir=$my_work$default_project_name

        curl "https://raw.githubusercontent.com/ahonymous/a2envhost/master/apache24_vhost.conf" >> $target_file;

        if [ ! -L $my_s_enabled ]; then
            ln -s $target_file $my_s_enabled;
        fi

        sed -i 's|{{DOMAIN_NAME}}|'$default_domain_name'|g' $target_file
        sed -i 's|{{ADMIN_EMAIL}}|'$default_email'|g' $target_file
        sed -i 's|{{PROJECT_DIR}}|'$project_dir'|g' $target_file
        sed -i 's|{{PROJECT_NAME}}|'$default_project_name'|g' $target_file

        if [[ ! $(grep $default_domain_name "/etc/hosts") ]]; then
            sudo sh -c "echo '127.0.0.1    $default_domain_name' >> /etc/hosts";
        fi
    fi
}

if [[ $(apache2ctl -M | grep rewrite) == /dev/null ]]; then
    sudo sh -c "a2enmod rewrite";
fi

if [[ $(apache2ctl -M | grep vhost_alias) == /dev/null ]]; then
    sudo sh -c "a2enmod vhost_alias";
fi

if [[ $(apache2ctl -M | grep headers) == /dev/null ]]; then
    sudo sh -c "a2enmod headers";
fi

if [[ $(apache2ctl -M | grep filter) == /dev/null ]]; then
    sudo sh -c "a2enmod filter";
fi

if [ $1 ]; then
    proj=$1;
    home ${proj};
else
    for proj in $(ls -l $my_work | egrep '^d' | awk '{print $9}'); do
        if [ $proj ]; then
            home ${proj};
        fi
    done
fi

sudo sh -c "service apache2 restart";