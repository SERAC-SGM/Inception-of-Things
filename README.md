# Inception of Things

This project aims to be an introduction to Kubernetes from a developer perspective. The goal is to set up small clusters and discover the mechanics of continuous integration.

There are 4 parts:

[Part 1](https://github.com/SERAC-SGM/Inception-of-Things/tree/main/p1) is about setting up 2 virtual machines using Vagrant, installing k3s in controller mode for the first one and in agent mode for the second one.

[Part 2](https://github.com/SERAC-SGM/Inception-of-Things/tree/main/p2) is about setting up a virtual machine (using Vagrant) running 3 web applications that can be accessed depening on the host header.

[Part 3](https://github.com/SERAC-SGM/Inception-of-Things/tree/main/p3) is about setting up an infrastructure using k3d containing an app that will be automatically deployed using ArgoCD and a [github repository](https://github.com/SERAC-SGM/lletourn-iot/tree/main).

[Part 4](https://github.com/SERAC-SGM/Inception-of-Things/tree/main/bonus) is similar to part 3, but this time instead of a github repo we will set up our own local gitlab server.
