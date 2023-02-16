exec { "apt-update":
    command => "/usr/bin/apt update"
}

package { "mysql-server":
    ensure => installed,
    require => Exec["apt-update"],
}

file { "/etc/mysql/conf.d/allow_external.cnf":
    content => template("/vagrant/manifests/templates/allow_ext.cnf"),
    require => Package["mysql-server"],
    notify  => Service["mysql"],    
}

service { "mysql":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package["mysql-server"],
}