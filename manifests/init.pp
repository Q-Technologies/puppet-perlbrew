# == class perlbrew
# @summary Installs perlbrew, perls and perl modules
#
# @example Basic usage
#   class { 'perlbrew': 
#     install_root => /usr/local/perlbrew,
#     owner => 'perl',
#     group => 'perl',
#     create_user => true,
#     rc_files => ['/etc/profile.d/perlbrew.sh'],
#   }
#
# @param install_root
#   Directory to install the perlbrew installation, defaults to '/opt/perlbrew'
# @param owner
#   Owner of the perlbrew files, defaults to 'perlbrew'
# @param group
#   Group of the perlbrew files, defaults to 'perlbrew'
# @param set_perms
#   Whether to set the install_root to these perms, defaults to true
# @param create_user
#   Whether to create the system user of these perms, defaults to true
# @param rc_files
#   A list of files to source the perlbrew environment from, defaults to ['/etc/profile.d/perlbrew.sh']
# @param prereqs
#   Used internally - it's a list of binaries to check for for this class to work.
#
class perlbrew (
  # Class parameters are populated from module hiera data or overridden by central hiera
  String  $install_root,
  String  $owner,
  String  $group,
  Boolean $set_perms,
  Boolean $create_user,
  Array[String] $rc_files,
  Array[String] $prereqs,
) {
  validate_absolute_path($install_root)

  $prereqs.each |$prereq| {
    exec { "check_${prereq}":
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
      command => "${prereq} --help >/dev/null",
      returns => 0,
      creates => "${install_root}/bin/perlbrew",
    }
  }

  if $create_user {
    group { $group:
      ensure => present,
      system => true,
    }
    user { $owner:
      ensure  => present,
      comment => 'Perlbrew user',
      gid     => $group,
      home    => $install_root,
      system  => true,
      require => Group[$group],
      before  => Exec["install_perlbrew into ${install_root}"],
    }
  }

  if $set_perms {
    file { $install_root:
      ensure => directory,
      group  => $group,
      owner  => $owner,
      before => Exec["install_perlbrew into ${install_root}"],
    }
  }

  exec { "install_perlbrew into ${install_root}":
    command     => 'curl -SsL -o - http://install.perlbrew.pl | bash',
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    environment => ["PERLBREW_ROOT=${install_root}"],
    cwd         => $install_root,
    user        => $owner,
    group       => $group,
    logoutput   => true,
    creates     => "${install_root}/bin/perlbrew",
  }
  -> exec { 'install-cpanm':
    command     => 'perlbrew install-cpanm',
    path        => ["${install_root}/bin",'/bin', '/usr/bin', '/usr/local/bin'],
    environment => ["PERLBREW_ROOT=${install_root}"],
    cwd         => $install_root,
    user        => $owner,
    group       => $group,
    logoutput   => true,
    creates     => "${install_root}/bin/cpanm",
  }
  -> class { 'perlbrew::versions': }
  -> class { 'perlbrew::modules': }

  $rc_files.each |$file| {
    # Make sure the file exists at least, but we don't want to manage it
    exec { $file:
      command => "touch ${file}",
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
      creates => $file,
    }
    -> file_line { $file:
      path => $file,
      line => "source ${install_root}/etc/bashrc",
    }
  }
}
