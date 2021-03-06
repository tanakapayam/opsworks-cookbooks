script "install_dependencies" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH

    apt-get install -y git
    apt-get install -y apache2
    apt-get install -y libapache2-mod-wsgi


    # postgresql dependencies
    #apt-get install -y python-dev
    #apt-get install -y libpq-dev
    apt-get install -y python-psycopg2

    # ubuntu pip package is currently broken
    # https://bugs.launchpad.net/ubuntu/+source/python-pip/+bug/1306991
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7

    # disable default apache site
    a2dissite 000-default

  EOH

end