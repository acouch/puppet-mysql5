class mysql5(
  $mysqlpassword,
  $webadminuser = "root",
  $webadmingroup = "root") {


   package { 'mysql-server':
     ensure => installed,
   }

   package { 'mysql-client':
     ensure => installed,
   }

   package { 'mysql-common':
     ensure => installed,
   }

   # Recommended here: http://projects.puppetlabs.com/issues/5610#note-13
   # /etc/init.d/mysql status fails without dbus installed but adding dbus as a package did
   # not fix that on first provision. Not sure why this works but it does.
   service { "mysql":
     alias => "mysql-server",
     ensure => running,
     enable => true,
     require => Package["mysql-server"],
     hasstatus => true,
   }

  # TODO: This only does the initial set, it won't reset it.
  exec { "Set MySQL server root password":
    refreshonly => true,
    unless => "mysqladmin -uroot -p$mysqlpassword status",
    path => "/bin:/usr/bin",
    command => "mysqladmin -uroot password $mysqlpassword",
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysqlpassword status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $mysqlpassword",
    require => Package["mysql-server"],
  }

  file { 'my.cnf':
    path => "/etc/mysql/my.cnf",
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/mysql5/my.cnf",
  }

  file { "root-mycnf":
    path => "/root/.my.cnf",
    content => template("mysql5/my.cnf.erb"),
    owner => root,
  }

  file { "admin-mycnf":
    path => "/home/$webadminuser/.my.cnf",
    content => template("mysql5/my.cnf.erb"),
    owner => $webadminuser,
    group => $webadmingroup,
  }

}

