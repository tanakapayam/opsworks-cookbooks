clone_repo = node['deploy'][0]['scm']['repository']["https://github.com/"]=""

script "deploy_app" do
  interpreter "bash"
  user "ubuntu"
  cwd "/home/ubuntu/"
  code <<-EOH

    REPO_NAME=#{node['django_app']['repo_name']}
    PROJECT_NAME=#{node['django_app']['project_name']}

    #disable default apache site
    sudo a2dissite 000-default

    sudo cat >> /etc/apache2/sites-available/site.conf << EOF
<VirtualHost *:80>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined

    Alias /static/ /home/ubuntu/$REPO_NAME/source/static/
    Alias /robots.txt /home/ubuntu/$REPO_NAME/source/static/robots.txt
    Alias /favicon.ico /home/ubuntu/$REPO_NAME/source/static/favicon.ico

    <Directory /home/ubuntu/$REPO_NAME/source/static/>
        Order deny,allow
        Require all granted
    </Directory>

    <Directory /home/ubuntu/$REPO_NAME/source/$PROJECT_NAME>
        <Files wsgi.py>
            Order deny,allow
            Require all granted
        </Files>
    </Directory>

    SetEnv DJANGO_SETTINGS_MODULE $PROJECT_NAME.settings.base

</VirtualHost>

WSGIScriptAlias / /home/ubuntu/$REPO_NAME/source/$PROJECT_NAME/wsgi.py
WSGIPythonPath /home/ubuntu/$PROJECT_NAME/source
EOF

    #install private SSH deploy key
    sudo cat >> /home/ubuntu/.ssh/id_rsa << EOF
#{node['deploy'][0]['scm']['ssh_key']}
EOF
    chmod 600 /home/ubuntu/.ssh/id_rsa
    git clone git@github.com: #{clone_repo} /home/ubuntu/#{node['django_app']['repo_name']} >> /home/ubuntu/log

    #todo: add env keys to environemnt

    #instal dependencies
    #todo: usepip and requirements.txt
    sudo pip install django

    sudo chown -R ubuntu /home/ubuntu/$REPO_NAME
    sudo chmod o+r /home/ubuntu/$REPO_NAME/source/$PROJECT_NAME/wsgi.py
    sudo chmod o+x /home/ubuntu/$REPO_NAME/source
    sudo chmod o+x /home/ubuntu/$REPO_NAME
    sudo chmod o+x /home/ubuntu
    sudo chmod o+x /home

    sudo a2ensite site
    sudo service apache2 reload
    sudo service apache2 start

  EOH

end