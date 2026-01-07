# OSV Compute SIP
#
# Local computational analysis, numerical modeling, and ML experimentation.
# Does NOT configure GPU drivers, cloud SDKs, or auto-start servers.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.compute;

  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    # Jupyter (installed, never auto-started)
    jupyter
    jupyterlab
    notebook
    ipykernel
    ipywidgets

    # Numerical computing
    numpy
    scipy
    sympy

    # Data analysis
    pandas

    # Visualization
    matplotlib
    seaborn
    plotly

    # Machine learning (CPU-based)
    scikit-learn
  ]);
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pythonWithPackages
      pkgs.R
      pkgs.julia-bin
    ];
    # Jupyter is a tool. Users start manually: jupyter notebook / jupyter lab
  };
}
