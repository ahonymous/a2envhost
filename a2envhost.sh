#!/usr/bin/env bash

my_work="$HOME/work/";
home () {
    local target_file="$HOME/etc/apache2/sites-available/$proj.conf";
    local my_s_enabled="$HOME/etc/apache2/sites-enabled/$proj.conf";

    if [[ -d $my_work && $(find $my_work"/"$proj -type d) ]]; then
        local default_domain_name="$proj.local";
        local default_email="$(git config --global user.email)";
        local default_project_name=$proj;
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

if [ $1 ]; then
    proj=$1;
    home '${proj}';
else
    for proj in $(ls -l $my_work | egrep '^d' | awk '{print $9}'); do
        if [ $proj ]; then
            home '${proj}';
        fi
    done
fi
