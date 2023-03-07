{ pkgs ? import <nixpkgs> {} }:

let

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
