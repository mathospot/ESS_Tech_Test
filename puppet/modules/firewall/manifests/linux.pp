# @summary Main linux class, includes all other classes
#
# @param ensure
#   Controls the state of the ipv4 iptables service on your system. Valid options: 'running' or 'stopped'. Defaults to 'running'.
#
# @param ensure_v6
#   Controls the state of the ipv6 iptables service on your system. Valid options: 'running' or 'stopped'. Defaults to 'running'.
#
# @param pkg_ensure
#   Controls the state of the iptables package on your system. Valid options: 'present', 'installed' or 'latest'. Defaults to 'latest'.
#
# @param service_name
#   Specify the name of the IPv4 iptables service. Defaults defined in firewall::params.
#
# @param service_name_v6
#   Specify the name of the IPv6 iptables service. Defaults defined in firewall::params.
#
# @param package_name
#   Specify the platform-specific package(s) to install. Defaults defined in firewall::params.
#
# @param ebtables_manage
#   Controls whether puppet manages the ebtables package or not. If managed, the package will use the value of pkg_ensure.
#
# @api private
#
class firewall::linux (
  Enum[running, stopped, 'running', 'stopped']                       $ensure          = running,
  Optional[Enum[running, stopped, 'running', 'stopped']]             $ensure_v6       = undef,
  Enum[present, installed, latest, 'present', 'installed', 'latest'] $pkg_ensure      = installed,
  Variant[String[1], Array[String[1]]]                               $service_name    = $firewall::params::service_name,
  Optional[String[1]]                                                $service_name_v6 = $firewall::params::service_name_v6,
  Optional[Variant[String[1], Array[String[1]]]]                     $package_name    = $firewall::params::package_name,
  Boolean                                                            $ebtables_manage = false,
  String[1]                                                          $iptables_name   = $firewall::params::iptables_name,
) inherits firewall::params {
  $enable = $ensure ? {
    'running' => true,
    'stopped' => false,
  }

  $_ensure_v6 = pick($ensure_v6, $ensure)

  $_enable_v6 = $_ensure_v6 ? {
    'running' => true,
    'stopped' => false,
  }

  package { 'iptables':
    ensure => $pkg_ensure,
    name   => $iptables_name,
  }

  if $ebtables_manage {
    package { 'ebtables':
      ensure => $pkg_ensure,
    }
  }

  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'SL', 'SLC', 'Ascendos',
    'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL', 'Amazon', 'XenServer',
    'VirtuozzoLinux', 'Rocky', 'AlmaLinux': {
      class { "${title}::redhat":
        ensure          => $ensure,
        ensure_v6       => $_ensure_v6,
        enable          => $enable,
        enable_v6       => $_enable_v6,
        package_name    => $package_name,
        service_name    => $service_name,
        service_name_v6 => $service_name_v6,
        require         => Package['iptables'],
      }
    }
    'Debian', 'Ubuntu': {
      class { "${title}::debian":
        ensure       => $ensure,
        enable       => $enable,
        package_name => $package_name,
        service_name => $service_name,
        require      => Package['iptables'],
      }
    }
    'Archlinux': {
      class { "${title}::archlinux":
        ensure       => $ensure,
        enable       => $enable,
        package_name => $package_name,
        service_name => $service_name,
        require      => Package['iptables'],
      }
    }
    'Gentoo': {
      class { "${title}::gentoo":
        ensure       => $ensure,
        enable       => $enable,
        package_name => $package_name,
        service_name => $service_name,
        require      => Package['iptables'],
      }
    }
    default: {}
  }
}
