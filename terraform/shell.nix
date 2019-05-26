{ pkgs ?  import <nixpkgs> { } }:

let

  terranix = pkgs.callPackage (pkgs.fetchgit {
    url = "https://github.com/mrVanDalo/terranix.git";
    rev = "2.1.0";
    sha256 = "00jqdnxz5zrypqkd4vh37ma5mh40rdzy3yfdqa410gb8hwrvyvfl";
  }) { };

  # a custom provider for terraform
  namecheapProvider = pkgs.buildGoPackage rec {
    name = "terraform-provider-namecheap-${version}";
    version = "1.2.0";
    goPackagePath = "github.com/adamdecaf/terraform-provider-namecheap";
    subPackages = [ "./" ];

    src = pkgs.fetchFromGitHub {
      owner = "adamdecaf";
      repo = "terraform-provider-namecheap";
      sha256 = "1c22zcjpfza60p6wsfbbf5z6jy2qz4h9lnkr5rdi6wi0pghs1yp8";
      rev = "${version}";
    };

    postBuild = "mv go/bin/terraform-provider-namecheap{,_v${version}}";

    meta = with pkgs.stdenv.lib; {
      homepage = https://github.com/adamdecaf/terraform-provider-namecheap;
      description = "Terraform provider is used to manage namecheap.com resources.";
      platforms = platforms.all;
      license = licenses.mpl20;
      maintainers = with maintainers; [ palo ];
    };
  };

  terraform = pkgs.terraform.withPlugins(p: [
    p.hcloud
    namecheapProvider
  ]);

in pkgs.mkShell {

  buildInputs = [

    # terraform wrapper to set access variables
    # -----------------------------------------
    (pkgs.writeShellScriptBin "terraform" ''
      export TF_VAR_hcloud_api_token=`${pkgs.pass}/bin/pass development/hetzner.com/api-token`
      export TF_VAR_namecheap_api_token=`${pkgs.pass}/bin/pass development/namecheap.com/api-token`
      ${terraform}/bin/terraform "$@"
    '')

    # terranix to avoid HCL
    # ---------------------
    terranix

    # tooling
    # -------
    pkgs.terraform-landscape
    pkgs.terraform-docs
    #pkgs.terragrunt

  ];

  shellHook = ''
    # save shell history in project folder
    HISTFILE=${toString ./.history}

    # configure password store to use subfolder
    export PASSWORD_STORE_DIR=./secrets
  '';

}
