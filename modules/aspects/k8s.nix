{ ... }:
{
  dots.k8s =
    { user, ... }:
    {
      description = "Kubernetes tools: kubectl, k9s, flux, talosctl";

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            kubectl
            fluxcd
            talosctl
          ];
          programs.k9s = {
            enable = true;
            plugins.inspect-pvc = {
              shortCut = "s";
              confirm = false;
              description = "Explore PVC";
              scopes = [ "persistentvolumeclaims" ];
              command = "sh";
              background = false;
              args = [
                "-c"
                ''
                  kubectl run --rm -it k9s-inspecting-''${NAMESPACE}-''${NAME} --image=busybox --restart=Never --namespace ''${NAMESPACE} --context ''${CONTEXT} --overrides='{
                      "spec": { "containers": [{ "image": "busybox", "name": "k9s-inspecting-''${NAMESPACE}-''${NAME}",
                        "volumeMounts": [{ "mountPath": "/inspecting-pvc-''${NAMESPACE}-''${NAME}", "name": "k9s-inspected-pvc" }],
                        "workingDir": "/inspecting-pvc-''${NAMESPACE}-''${NAME}", "stdin": true, "tty": true, "imagePullPolicy": "Always" }],
                        "volumes": [{ "name": "k9s-inspected-pvc", "persistentVolumeClaim": { "claimName": "''${NAME}" } }] }
                  }' --command -- sh
                ''
              ];
            };
          };
        };
    };
}
