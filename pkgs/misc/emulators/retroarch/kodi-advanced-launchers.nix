{ stdenv, pkgs, cores }:

assert cores != [];

with pkgs.lib;

let

  script = exec: ''
    #!${stdenv.shell}
    nohup sh -c "sleep 1 && pkill -SIGSTOP kodi" &
    nohup sh -c "${exec} '$@' -f;pkill -SIGCONT kodi"
  '';
  scriptSh = exec: pkgs.writeScript ("kodi-"+exec.name) (script exec.path);
  execs = map (core: rec { name = core.core; path = core+"/bin/retroarch-"+name;}) cores;

in

stdenv.mkDerivation rec {
  name = "kodi-retroarch-advanced-launchers-${version}";
  version = "0.2";

  dontBuild = true;

  buildCommand = ''
    mkdir -p $out/bin
    ${stdenv.lib.concatMapStrings (exec: "ln -s ${scriptSh exec} $out/bin/kodi-${exec.name};") execs}
  '';

  meta = {
    description = "Kodi retroarch advanced launchers";
    longDescription = ''
      These retroarch launchers are intended to be used with
      anglescry advanced launcher for Kodi since device input is
      caught by both Kodi and the retroarch process.
    '';
    license = stdenv.lib.licenses.gpl3;
  };
}
