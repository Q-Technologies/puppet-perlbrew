# == Class: perlbrew::versions
# @summary Installs specified perls into perlbrew
#
# @example Example Hiera Data
#   perlbrew::versions::install:
#   - 5.32.1
#   - 5.36.0
#
# @param install
#   A list of versions to be installed
# @param build_timeout
#   How long puppet should wait in seconds before it times out the build and install of the version.  
#   Defaults to 900 seconds.
# @param build_flags
#   The flags to pass to perlbrew for the install of the version, defaults to 
#   '--notest -j %{facts.processorcount}'
# @param purge_builds
#   Whether to purge the temporary build files after the install of the version, defaults to true
#
class perlbrew::versions (
  # Class parameters are populated from module hiera data or overridden by central hiera
  Array[String] $install,
  # Hash $switched_on,
  String $build_flags,
  Integer $build_timeout,
  Boolean $purge_builds,
) {
  $install_root = $perlbrew::install_root
  $owner        = $perlbrew::owner
  $group        = $perlbrew::group

  $install.each |$version| {
    $perlbrew_env = [
      "HOME=${install_root}",
      "PERLBREW_PERL=${version}",
      "PERLBREW_ROOT=${install_root}",
      "PERLBREW_HOME=${install_root}/.perlbrew",
      "PERLBREW_MANPATH=${install_root}/perls/${version}/man",
      "PERLBREW_PATH=${install_root}/bin:${install_root}/perls/${version}/bin",
    ]

    $perlbrew_path = [
      "${install_root}/bin",
      "${install_root}/perls/${version}/bin",
      '/bin',
      '/usr/bin',
    ]

    $command = regsubst("perlbrew install ${build_flags} ${version}", '\s+', ' ', 'G')

    exec { "install_${version}":
      command     => $command,
      path        => $perlbrew_path,
      environment => $perlbrew_env,
      cwd         => $install_root,
      user        => $owner,
      group       => $group,
      logoutput   => true,
      creates     => "${install_root}/perls/perl-${version}",
      timeout     => $build_timeout,
    }
    if $purge_builds {
      exec { "purging ${version} build data":
        command => "/bin/rm -fr ${install_root}/build/perl-${version}",
        onlyif  => "/bin/ls -d ${install_root}/build/perl-${version}",
        require => Exec["install_${version}"],
      }
      exec { "purging ${version} build log":
        command => "/bin/rm -fr ${install_root}/build.perl-${version}.log",
        onlyif  => "/bin/ls -d ${install_root}/build.perl-${version}.log",
        require => Exec["install_${version}"],
      }
    }
  }
  # I think I will abandon this idea - it's a bit impossible without knowing someones
  # home directory location.  It doesn't really make a lot of sense for Puppet to set
  # user preferences anyway.  The perlbrew selection for users should be made in any puppet
  # code that manages the users

  # $switched_on.each |$user,$version| {

  #   $perlbrew_path = [
  #     "${install_root}/bin",
  #     "${install_root}/perls/${version}/bin",
  #     '/bin',
  #     '/usr/bin',
  #   ]

  #   $perlbrew_env = [
  #     "HOME=${install_root}",
  #     "PERLBREW_PERL=${version}",
  #     "PERLBREW_ROOT=${install_root}",
  #     "PERLBREW_HOME=${install_root}/.perlbrew",
  #     "PERLBREW_MANPATH=${install_root}/perls/${version}/man",
  #     "PERLBREW_PATH=${install_root}/bin:${install_root}/perls/${version}/bin",
  #   ]

  #   exec { "$switch_${version}_for_${user}":
  #     command     => "perlbrew switch ${version}",
  #     path        => $perlbrew_path,
  #     environment => $perlbrew_env,
  #     cwd         => $install_root,
  #     user        => $user,
  #     logoutput   => true,
  #     unless      => "grep PERLBREW_PERL=\\\"${version}\\\" ${install_root}/.perlbrew/init",
  #   }

  # }
}
