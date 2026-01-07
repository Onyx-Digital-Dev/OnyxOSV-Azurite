# OSV Compute SIP (Software Intent Profile)
#
# PURPOSE:
# "This workstation enables local computational analysis, numerical
# modeling, and machine learning experimentation without coupling to
# specific accelerators, cloud services, or production infrastructure."
#
# CAPABILITIES:
#   - Run Jupyter notebooks locally (installed, NOT auto-started)
#   - Perform numerical computing (NumPy, SciPy)
#   - Analyze and manipulate tabular data (pandas)
#   - Create statistical visualizations (matplotlib, seaborn)
#   - Execute R statistical computing workflows
#   - Run local ML experimentation with CPU-based frameworks
#   - Use Julia for scientific computing
#
# BOUNDARY: This module provides compute TOOLS ONLY.
# It does NOT configure:
#   - GPU drivers (CUDA, ROCm, OpenCL)
#   - Accelerator detection or policy
#   - Cloud SDKs (AWS, GCP, Azure CLI)
#   - Production ML serving (TensorFlow Serving, Triton)
#   - Automatic Jupyter server (installed but NEVER auto-started)
#   - Big data infrastructure (Spark, Hadoop, distributed compute)
#   - Database servers
#
# EXPLICIT EXCLUSIONS:
#   - GPU-specific ML frameworks (users configure acceleration separately)
#   - Cloud provider tooling
#   - Production deployment infrastructure
#
# COMPOSABILITY:
#   This SIP is designed to work alongside all other SIPs without conflicts.
#   Overlaps with Developer SIP (Python) are intentional and acceptable.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.compute;

  # Python environment with scientific stack
  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    # ─────────────────────────────────────────────────────────────────────
    # Jupyter Notebook Environment
    # ─────────────────────────────────────────────────────────────────────
    jupyter
    jupyterlab
    notebook
    ipykernel
    ipywidgets

    # ─────────────────────────────────────────────────────────────────────
    # Numerical Computing
    # ─────────────────────────────────────────────────────────────────────
    numpy
    scipy
    sympy             # Symbolic mathematics

    # ─────────────────────────────────────────────────────────────────────
    # Data Analysis
    # ─────────────────────────────────────────────────────────────────────
    pandas
    polars            # Fast DataFrame library

    # ─────────────────────────────────────────────────────────────────────
    # Visualization
    # ─────────────────────────────────────────────────────────────────────
    matplotlib
    seaborn
    plotly

    # ─────────────────────────────────────────────────────────────────────
    # Machine Learning (CPU-based)
    # ─────────────────────────────────────────────────────────────────────
    scikit-learn      # Classical ML algorithms
  ]);
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # ─────────────────────────────────────────────────────────────────────
      # Python Scientific Stack
      # ─────────────────────────────────────────────────────────────────────
      pythonWithPackages

      # ─────────────────────────────────────────────────────────────────────
      # R Statistical Computing
      # ─────────────────────────────────────────────────────────────────────
      pkgs.R
      pkgs.rstudio      # RStudio IDE

      # ─────────────────────────────────────────────────────────────────────
      # Julia Scientific Computing
      # ─────────────────────────────────────────────────────────────────────
      pkgs.julia-bin    # Julia language

      # ─────────────────────────────────────────────────────────────────────
      # GNU Octave (MATLAB-compatible)
      # ─────────────────────────────────────────────────────────────────────
      pkgs.octave       # Numerical computing environment
    ];

    # ═══════════════════════════════════════════════════════════════════════
    # EXPLICIT: NO JUPYTER SERVER AUTO-START
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Jupyter is installed as a TOOL. Users start it manually:
    #   $ jupyter notebook
    #   $ jupyter lab
    #
    # This SIP does NOT enable services.jupyter or any auto-start mechanism.
    # ═══════════════════════════════════════════════════════════════════════
  };
}
