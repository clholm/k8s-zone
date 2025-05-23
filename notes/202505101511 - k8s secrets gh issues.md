**there are several github issues regarding secrets visibility:**
- Secrets created with kubectl apply -f are available as clear text in "Annotations" #29923
	- https://github.com/kubernetes/kubernetes/issues/29923
```
"That issue was closed as working as designed. Metadata is not treated as less confidential than main object content by encryption at rest or authorization."
```
- kubectl apply leaks secret data #23564
	- https://github.com/kubernetes/kubernetes/issues/23564
- Allow listing secrets without disclosing secret data #78056
	- https://github.com/kubernetes/kubernetes/issues/78056
```
"Thanks for the feature request, but this is unlikely to make progress as an issue. A proposal that works through the design along with the implications of such a change can be opened as a [KEP]"(https://github.com/kubernetes/enhancements/tree/master/keps#kubernetes-enhancement-proposals-keps).
```
- Accessing non-sensitive data of Secrets #86268
	- https://github.com/kubernetes/kubernetes/issues/86268
- (~related issue) kubectl describe secrets skips annotations by default #89600
	-  https://github.com/kubernetes/kubernetes/issues/89600
```
"This was discussed earlier today during SIG-CLI and the overall sentiment is that this won't be solved. We advised towards either improved server-side describe which at some point will allow further dynamic printing (maybe in the future), but overall the suggestion was that original author should check out server-side apply to start with."
```
- (~related PR) filter lastAppliedConfig annotation for describe secret #34664
	- https://github.com/kubernetes/kubernetes/pull/34664

**there are several issues related to this for various k8s tools:**
- `airshipctl`: Secret stringData Encoding #424
	- https://github.com/airshipit/airshipctl/issues/424
- `pulumi-kubernetes:` last-applied-configuration contains plain text secret values #1118
	- https://github.com/pulumi/pulumi-kubernetes/issues/1118
- `kube-applier:` Output kubectl apply errors without leaking Secrets from annotations #118
	- https://github.com/utilitywarehouse/kube-applier/issues/118
- `kapp`: improve kubectl describe output of kapp managed secrets #90
	- https://github.com/carvel-dev/kapp/issues/90
- `bundle-kubeflow`: The mlpipeline-minio-artifact contains the value in open text in annotation #446
	- https://github.com/canonical/bundle-kubeflow/issues/446

**`kubectl` documentation also describes using `kubectl apply` to create secrets:**
- Managing Secrets using Configuration File
	- https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-config-file/

