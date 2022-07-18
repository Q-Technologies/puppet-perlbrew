# @summary Installs perl modules into specified perlbrew perls.  It is called from
#   the perlbrew class, so it just needs hiera data to configure it.  cpanm does the install
#   of the modules.
#
# @example Example Hiera Data
#   perlbrew::modules::install:
#     5.32.1:
#     - Module::Build
#     5.36.0:
#     - Module::Build
#     - String::ShortHostname
#     - Dancer2
#
# @param install
#   A list of modules to be installed, specified per perl version installed
# @param build_timeout
#   How long puppet should wait in seconds before it times out the build and install of the module.  
#   Defaults to 900 seconds.  Just be careful to make sure it is long enough to get all the
#   prereqs as well as they will all be included in the one build timeout unless they are separately
#   specified.
# @param build_flags
#   The flags to pass to cpanm for the install of the modules, defaults to '--notest'
#
class perlbrew::modules (
  # Class parameters are populated from module hiera data or overridden by central hiera
  Hash $install,
  Integer $build_timeout,
  String $build_flags,
) {
  $install_root = $perlbrew::install_root
  $owner        = $perlbrew::owner
  $group        = $perlbrew::group

  $install.each |$version,$modules| {
    $perlbrew_env = [
      "PERLBREW_PERL=${version}",
      "PERLBREW_ROOT=${install_root}",
      "HOME=${install_root}",
    ]

    $perlbrew_path = [
      "${install_root}/bin",
      "${install_root}/perls/${version}/bin",
      '/bin',
      '/usr/bin',
    ]

    $modules.each |$module| {
      exec { "install ${module} in perl-${version}":
        command     => "perlbrew exec --with perl-${version} cpanm ${build_flags} ${module}",
        path        => $perlbrew_path,
        environment => $perlbrew_env,
        cwd         => $install_root,
        user        => $owner,
        group       => $group,
        logoutput   => true,
        unless      => "perlbrew exec --with perl-${version} perldoc ${module} >/dev/null",
        timeout     => $build_timeout,
      }
    }
  }
}
