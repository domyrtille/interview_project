  <!-- 
  _____ _   _ _______ ______ _______      _______ ________          __  _____   ____   _____ _    _ __  __ ______ _   _ _______    _______ _____ ____  _   _ 
 |_   _| \ | |__   __|  ____|  __ \ \    / /_   _|  ____\ \        / / |  __ \ / __ \ / ____| |  | |  \/  |  ____| \ | |__   __|/\|__   __|_   _/ __ \| \ | |
   | | |  \| |  | |  | |__  | |__) \ \  / /  | | | |__   \ \  /\  / /  | |  | | |  | | |    | |  | | \  / | |__  |  \| |  | |  /  \  | |    | || |  | |  \| |
   | | | . ` |  | |  |  __| |  _  / \ \/ /   | | |  __|   \ \/  \/ /   | |  | | |  | | |    | |  | | |\/| |  __| | . ` |  | | / /\ \ | |    | || |  | | . ` |
  _| |_| |\  |  | |  | |____| | \ \  \  /   _| |_| |____   \  /\  /    | |__| | |__| | |____| |__| | |  | | |____| |\  |  | |/ ____ \| |   _| || |__| | |\  |
 |_____|_| \_|  |_|  |______|_|  \_\  \/   |_____|______|   \/  \/     |_____/ \____/ \_____|\____/|_|  |_|______|_| \_|  |_/_/    \_\_|  |_____\____/|_| \_| 
 -->

# Interview exercises


### Dockerfile
The [dockerfile](https://github.com/domyrtille/interview/blob/main/Dockerfile) with a multi-build stage will build an image for a LTC node with the necessaries libs and security to make it works and secure
The final image is based on an Ubuntu folca which, right now as now CVE's above low, which compared to Alpine is better


### Kubernetes
The [statefulset](https://github.com/domyrtille/interview/blob/main/kube/ltc_statefulset.yaml) has multiple objects like PV that is backed by an EBS disk on AWS with 75G request
As the Litecoin blockchain is around 64G, 75 will let us have some time if we need to add or change the disk

### Continuous integration
The CI has been done with Travis, [.travis.yaml](https://github.com/domyrtille/interview/blob/main/.travis.yml) and use the docker service to facilitate the use of different images:
 - hadolint as linter for the Dockerfile
 - kubeval as a tool to validate the kubernetes yaml file
 - kubescore as linter for the kubernetes object in the yaml file

```bash
###############
FROM TRAVIS CI
###############
$ docker run --rm -i hadolint/hadolint < Dockerfile
// If nothing shows, it means linter passed

$ docker run --rm -v $(pwd):/project garethr/kubeval "/project/kube/ltc_statefulset.yaml"
PASS - /project/kube/ltc_statefulset.yaml contains a valid PersistentVolume (ltc_node_pv)
PASS - /project/kube/ltc_statefulset.yaml contains a valid PersistentVolumeClaim (ltc_node_pvc)
PASS - /project/kube/ltc_statefulset.yaml contains a valid StatefulSet (litecoin.litecoin_node)

$ docker run -v $(pwd):/project zegl/kube-score:v1.10.0 score --ignore-test pod-networkpolicy --ignore-test statefulset-has-servicename kube/*.yaml
apps/v1/StatefulSet litecoin_node in litecoin   ✅
```

The other steps once tests have been done and passed:
 - we build the image with the latest ltc release version, here 0.18.1
 - we then add the latest tag, for use by certain teams that doesn't need specific version, but just the latest build
 - we push the image to a public registry, mostly for demo purposes, otherwise it will be pushed on a private repo, either on managed service or internal one


Last step is to use Anchore/grype tool to analyse the image built for any CVE's. It has been configured so that if any CVEs are at least medium, it will faild the build
Like that we can work on it and repush on fixed

```bash
NAME        INSTALLED                 FIXED-IN  VULNERABILITY     SEVERITY   

bash        5.0-6ubuntu1.1                      CVE-2019-18276    Low         
coreutils   8.30-3ubuntu2                       CVE-2016-2781     Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2020-6096     Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2021-3326     Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2019-25013    Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2016-10228    Negligible  
libc-bin    2.31-0ubuntu9.2                     CVE-2020-27618    Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2021-27645    Low         
libc-bin    2.31-0ubuntu9.2                     CVE-2020-29562    Low         
libc6       2.31-0ubuntu9.2                     CVE-2020-6096     Low         
libc6       2.31-0ubuntu9.2                     CVE-2021-3326     Low         
libc6       2.31-0ubuntu9.2                     CVE-2019-25013    Low         
libc6       2.31-0ubuntu9.2                     CVE-2016-10228    Negligible  
libc6       2.31-0ubuntu9.2                     CVE-2020-27618    Low         
libc6       2.31-0ubuntu9.2                     CVE-2021-27645    Low         
libc6       2.31-0ubuntu9.2                     CVE-2020-29562    Low         
libpcre3    2:8.39-12build1                     CVE-2020-14155    Negligible  
libpcre3    2:8.39-12build1                     CVE-2017-11164    Negligible  
libpcre3    2:8.39-12build1                     CVE-2019-20838    Low         
libtasn1-6  4.16.0-2                            CVE-2018-1000654  Negligible  
login       1:4.8.1-1ubuntu5.20.04.1            CVE-2013-4235     Low         
passwd      1:4.8.1-1ubuntu5.20.04.1            CVE-2013-4235     Low                                  
```


### Script
#### CLI
I used one of my use case I had recently (quite modified for obvious reaons).
We have lot of Big log files and sometimes we need to grep all IPs in it and modify them by something else that our system can understand
For that, I used different CLIs to do it:

    # Sometimes some computer can have disk/io issue so I remove all the line after 10000 (for example)
    # To avoid any error message with insufisient space on disk, sometimes I reduce the number of lines
      $ wc -l file.log
        94860 file.log
      $ sed -i -r '10001,94860d' file.log
      $ wc -l file.log
        10000 file.log

    # Once file is good, I can start the tasks
    # Here, I retrieve all IPs, filter them to only one occurence of them and put the result in another file called list_ip
    # Internaltool checker checks when we do some testing if gateway stop traffic from IP when there's too much tries with it
      $ cat file.log | grep -oE "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})" | uniq > list_ip
    # Sometimes we need to keep trace on how much time if it's above a certain tresholds(for demo, here 3) an IP is found in the logs
      $ cat file.log | grep -oE "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})" | uniq -c | sort | awk '$1 >=3  { print $2 > "list_ip" }'
      

    # When it's done, another command cat the file and change the ip by something else, here for demo purposes it will be demo
      $ cat list_ip | while read line ; do echo $line ; sed -i'' -r "s/$line/demo/g" file.log; done

If there is an issue, to be able to track IP on the plateform, from different campaign to different system, check if it appear somewhere else and if it's normal

#### Python

### Terraform
Everything on our [Terraform module](https://github.com/domyrtille/interview/tree/main/terraform_module_prod_ci) has been done to create everything on AWS

### Optimization TODO
  - Cache docker image in travis to avoid Dl at each build
  - A script that change the LTC_Version fron 0.18.1 to 0.18.1.$Gitcommit if any optimization need to be done on the image
  - Bootstrap data inside the container to speed the sync
    - https://litecoin.info/index.php/Bootstrap.dat
  - Better argument and cli with python script
