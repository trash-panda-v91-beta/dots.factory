{
  delib,
  ...
}:
delib.module {
  name = "programs.opencode.permissions";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode.settings.permission = {
      edit = "allow";
      bash = {
        "git status*" = "allow";
        "git log*" = "allow";
        "git diff*" = "allow";
        "git show*" = "allow";
        "git branch*" = "allow";
        "git remote*" = "allow";
        "git config*" = "allow";
        "git rev-parse*" = "allow";
        "git ls-files*" = "allow";
        "git ls-remote*" = "allow";
        "git describe*" = "allow";
        "git tag --list*" = "allow";
        "git blame*" = "allow";
        "git shortlog*" = "allow";
        "git reflog*" = "allow";
        "git add*" = "allow";

        "nix search*" = "allow";
        "nix eval*" = "allow";
        "nix show-config*" = "allow";
        "nix flake show*" = "allow";
        "nix flake check*" = "allow";
        "nix log*" = "allow";

        "ls*" = "allow";
        "pwd*" = "allow";
        "find*" = "allow";
        "grep*" = "allow";
        "rg*" = "allow";
        "cat*" = "allow";
        "head*" = "allow";
        "tail*" = "allow";
        "mkdir*" = "allow";
        "chmod*" = "allow";

        "systemctl list-units*" = "allow";
        "systemctl list-timers*" = "allow";
        "systemctl status*" = "allow";
        "journalctl*" = "allow";
        "dmesg*" = "allow";
        "env*" = "allow";
        "nh search*" = "allow";

        "pactl list*" = "allow";
        "pw-top*" = "allow";

        "kubectl get*" = "allow";
        "kubectl describe*" = "allow";
        "kubectl logs*" = "allow";
        "kubectl explain*" = "allow";
        "kubectl api-resources*" = "allow";
        "kubectl api-versions*" = "allow";
        "kubectl cluster-info*" = "allow";
        "kubectl version*" = "allow";
        "kubectl config view*" = "allow";
        "kubectl config get-contexts*" = "allow";
        "kubectl config current-context*" = "allow";
        "kubectl top*" = "allow";
        "kubectl diff*" = "allow";

        "git reset*" = "ask";
        "git commit*" = "ask";
        "git push*" = "ask";
        "git pull*" = "ask";
        "git merge*" = "ask";
        "git rebase*" = "ask";
        "git checkout*" = "ask";
        "git switch*" = "ask";
        "git stash*" = "ask";

        "rm*" = "ask";
        "mv*" = "ask";
        "cp*" = "ask";

        "systemctl start*" = "ask";
        "systemctl stop*" = "ask";
        "systemctl restart*" = "ask";
        "systemctl reload*" = "ask";
        "systemctl enable*" = "ask";
        "systemctl disable*" = "ask";

        "kubectl apply*" = "ask";
        "kubectl create*" = "ask";
        "kubectl delete*" = "ask";
        "kubectl edit*" = "ask";
        "kubectl patch*" = "ask";
        "kubectl replace*" = "ask";
        "kubectl scale*" = "ask";
        "kubectl rollout*" = "ask";
        "kubectl set*" = "ask";
        "kubectl drain*" = "ask";
        "kubectl cordon*" = "ask";
        "kubectl uncordon*" = "ask";
        "kubectl taint*" = "ask";
        "kubectl label*" = "ask";
        "kubectl annotate*" = "ask";
        "kubectl exec*" = "ask";
        "kubectl run*" = "ask";
        "kubectl expose*" = "ask";
        "kubectl port-forward*" = "ask";
        "kubectl proxy*" = "ask";
        "kubectl cp*" = "ask";
        "kubectl attach*" = "ask";
        "kubectl debug*" = "ask";
        "kubectl config set*" = "ask";
        "kubectl config use-context*" = "ask";

        "curl*" = "ask";
        "wget*" = "ask";
        "ping*" = "ask";
        "ssh*" = "ask";
        "scp*" = "ask";
        "rsync*" = "ask";

        "sudo*" = "ask";
        "nixos-rebuild*" = "ask";

        "kill*" = "ask";
        "killall*" = "ask";
        "pkill*" = "ask";
      };
      read = "allow";
      list = "allow";
      glob = "allow";
      grep = "allow";
      webfetch = "allow";
      write = "allow";
      task = "allow";
      todowrite = "allow";
      todoread = "allow";
    };
  };
}
