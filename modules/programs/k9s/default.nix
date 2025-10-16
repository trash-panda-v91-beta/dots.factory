{ delib, host, ... }:
delib.module {
  name = "programs.k9s";
  options.programs.k9s = with delib; {
    enable = boolOption host.kubernetesFeatured;
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.k9s = {
        enable = cfg.enable;
        plugins = {
          inspect-pvc = {
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
                    "spec": {
                        "containers": [
                            {
                                "image": "busybox",
                                "name": "k9s-inspecting-''${NAMESPACE}-''${NAME}",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/inspecting-pvc-''${NAMESPACE}-''${NAME}",
                                        "name": "k9s-inspected-pvc"
                                    }
                                ],
                                "workingDir": "/inspecting-pvc-''${NAMESPACE}-''${NAME}",
                                "stdin": true,
                                "tty": true,
                                "imagePullPolicy": "Always"
                            }
                        ],
                        "volumes": [
                            {
                                "name": "k9s-inspected-pvc",
                                "persistentVolumeClaim": {
                                    "claimName": "''${NAME}"
                                }
                            }
                        ]
                    }
                }' --command -- sh
              ''
            ];
          };
        };
      };
    };
}
