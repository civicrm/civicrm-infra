# { pkgs ? import <nixpkgs> {} }:
## For unclear reasons, when using nixpkgs `22.11` and `unstable`, I'm
## having trouble with locale data. So "pkgs" is pinned to 22.05.

let

  pkgs = import(fetchTarball { ## nixos-22.05
    url = "https://github.com/nixos/nixpkgs/archive/ce6aa13369b667ac2542593170993504932eb836.tar.gz";
    sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
  }) {};

  ## Python Setup - Some Ansible plugins may require extra packages.
  myPythonPackages = p: with p; [
    requests
    google-auth
    ## ^^ If this doesn't build, you may need to update to newer nixpkgs.
  ];
  myPython = pkgs.python3.withPackages myPythonPackages;

in pkgs.mkShell {
  packages = [
    pkgs.ansible
    pkgs.php81
    # myPython
    ## ^^ Not using any plugins at the moment
  ];
  #shellHook = ''
  #  export ANSIBLE_HOME=$(pwd)
  #'';
}
