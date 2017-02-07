# class kubernetes::master
class kubernetes::scheduler(
  $ca_file = undef,
  $cert_file = undef,
  $key_file = undef,
)  {
  require ::kubernetes

  $service_name = 'kube-scheduler'

  $kubeconfig_path = "${::kubernetes::config_dir}/kubeconfig-scheduler"

  kubernetes::symlink{'scheduler':} ->
  file{$kubeconfig_path:
    ensure  => file,
    mode    => '0640',
    owner   => 'root',
    group   => $kubernetes::group,
    content => template('kubernetes/kubeconfig.erb'),
    notify  => Service["${service_name}.service"],
  }

  file{"${::kubernetes::systemd_dir}/${service_name}.service":
    ensure  => file,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => template("kubernetes/${service_name}.service.erb"),
    notify  => Service["${service_name}.service"],
  } ~>
  exec { "${service_name}-daemon-reload":
    command     => 'systemctl daemon-reload',
    path        => $::kubernetes::path,
    refreshonly => true,
  } ->
  service{ "${service_name}.service":
    ensure => running,
    enable => true,
  }

}
