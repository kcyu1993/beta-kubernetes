## Beta-Kubernetes
Adapted version for personal usage.

### Prerequisites and Install
0. Clone this repo
1. Request an account to the support (support-icit@epfl.ch)
2. If you plan to use a shared storage, request a volume  to the support
3. Install and Set Up kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/
    * Install kubectl binary via curl (Follow the instruction).
    * `mkdir ~/.kube/`
    * `mv config ~/.kube/` where `config` is the configuration file sent by EPFL IT.
4. Check if you setup works correctly
```sh
$ kubectl get pods     
No resources found
```

### Test: Create your first Pod (Container)
```sh
$ kubectl create -f ubuntu.yaml     
pod "ubuntu" created
```
Now list all pods running:
```sh
$ kubectl get pods
NAME      READY     STATUS    RESTARTS   AGE
ubuntu    1/1       Running   0          13s
```
You can log in to your pod
```sh
$ kubectl exec -it ubuntu -- /bin/bash
root@ubuntu:/# exit
exit
```

### Test: Using GPUs inside Pods
```sh
$ kubectl create -f pod-ubuntu-gpu.yaml
pod "ubuntu-gpu" created

$ kubectl exec -it ubuntu-gpu -- /bin/bash
root@ubuntu-gpu:/# nvidia-smi                                                                                                                                         
Tue Sep 26 14:00:03 2017       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 375.66                 Driver Version: 375.66                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX TIT...  Off  | 0000:04:00.0     Off |                  N/A |
|  0%   38C    P0    52W / 250W |      0MiB / 12207MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID  Type  Process name                               Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
root@ubuntu-gpu:/#
```


### Test: Using a shared storage across Pods
0. Request a Persistent Volume (**PV**) to the support **(Only admins can create a PV)**, then you will be able to create a Persistent Volume Claims (**PVC**).
1. Edit the file pvc-lamp-project.yaml and replace the name with the value provided by the support, in this case it's with a NFS share.

2. Create the PVC
```sh
$ kubectl create -f pvc-lamp-project.yaml
persistentvolumeclaim "pvc-nfs-mlo" created
```

3. Create the Pods
   1. Change the values for the name and the label in yaml files. You can also change settings like the root password with the environment variables in the yaml file for mysql pod.
   2. Create a nginx pod.
   ```sh
   $ kubectl create  -f pod-nginx.yaml
   pod "caperez-pod-nginx" created
   ```

   In this example, the sub folder "nginx" from the PVC will be mounted `/usr/share/nginx/html` in the pod.

   3. Create a mysql pod
   ```sh
   $ kubectl create -f pod-mysql.yaml
   pod "caperez-pod-mysql" created
   ```

   The sub folder "mysql" from the PVC will be mounted `/var/lib/mysql` in the pod

   4. Create a ubuntu pod to check the two folders.
   ```sh
   $ kubectl create -f pod-ubuntu-pvc.yaml
   Error from server (AlreadyExists): error when creating "ubuntu.yaml": object is being deleted: pods "ubuntu" already exists
   ```

   In this case, the ubuntu pod already exist. Suppress it, wait a while and try again.
   ```sh
   $ kubectl delete -f ubuntu.yaml
   pod "ubuntu" deleted
   ....
   $ kubectl create -f pod-ubuntu-pvc.yaml
   pod "ubuntu" created

   $ kubectl exec -it ubuntu -- /bin/bash
   root@ubuntu:/# ls -l /shared_volume
   total 8
   drwxr-xr-x 5  999  999 4096 Sep 26 11:33 mysql
   drwxr-xr-x 2 root root 4096 Sep 26 11:32 nginx
   root@ubuntu:/#
   ```

   We can see the two folders. The pod mounted the shared volume in /shared_volume **(without sub folder)**
