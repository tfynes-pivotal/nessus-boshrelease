# Bosh release for McAfee EPO agents

This is a [BOSH](http://bosh.io/) release to deploy [McAfee ePolicy Orchestrator agents](http://www.mcafee.com/us/downloads/endpoint-protection/products/epolicy-orchestrator.aspx).

## Disclaimer

This is NOT presently a production ready BOSH release. This is just a Proof of Concept. It is suitable for experimentation and may not become supported in the future.

## Usage

### Download the McAfee Agent for Linux

Each McAfee ePolicy Orchestrator server requires a special Agent's configuration and certificates. For security reasons, it is NOT a good idea to store this configuration on a public blobstore. Therefore, this BOSH release does NOT contain any McAfee ePO agent, so you must download it from your McAfee ePO server.

Login into your McAfee ePO server, and on the `System Selection` page, click on `New Systems`. A new window will appear. Select `Create and download agent installation package` and then select the `McAfee Agent for Linux`. A `install.sh` file will be downloaded to your workstation.

From here, there are two different approaches to inject the McAfee Agents into this BOSH release:

* Store the McAfee Agent for Linux at the BOSH release: copy the downloaded `install.sh` script into the `src/cma-agent/` directory.
* Specify a download URL for the McAfee Agent for Linux: using the `static buildpack` you can create a Cloud Foundry application that only contains the McAfee Agent for Linux. Create a new directory, store the `install.sh` inside this directory and create an empty `Staticfile` file. Then push this directory into your Cloud Foundry environment.

### Create a development BOSH release

```
git clone https://github.com/cf-platform-eng/mcafee-boshrelease.git
cd mcafee-boshrelease
bosh create release --force
```

### Upload the BOSH release

Using the previously created development BOSH release, upload it to your BOSH director:

```
bosh target BOSH_HOST
bosh upload release dev_releases/mcafee/mcafee/mcafee-0+dev.1.yml
```

*Note: replace `mcafee-0+dev.1.yml` with the name of the release version previously created*

### Deploy the McAfee Agent

There are two different approaches to deploy the McAfee Agent into all your VMs:

* Add the `mcafeee` release and the `cma_agent` job template to all jobs in your deployment manifest:

  ```
  releases:
     ...
    - name: mcafee
      version: latest
  
  ...
  
  jobs:
    - name: nats
      templates:
        - name: nats
          release: cf
        - name: metron_agent
          release: cf
        - name: cma_agent
          release: mcafee
  
  ...
  
  properties:
    cma_agent:
      system_owner: "PIVOTAL"
      system_project: "CloudFoundry"
  ```

  If you decided to specify a download URL for the McAfee Agent for Linux instead of embedding it into the BOSH release, you must also add the `cma_agent.download_url` property:

  ```
  properties:
    cma_agent:
      system_owner: "PIVOTAL"
      system_project: "CloudFoundry"
      download_url: "http://<MY CF APPS DOMAIN>/install.sh"
  ```

* If you are using a BOSH 2.0 director, you can add the release as a [BOSH Add-on](http://bosh.io/docs/runtime-config.html#addons). This will mean that the McAfee Agents will be deployed on all VM's without the need to specify it manually on each deployment manifest.

  Create a new file (ie `macafee.yml`) and paste the following content:

  ```
  releases:
    - name: mcafee
      version: latest

  addons:
    - name: mcafee
      jobs:
        - name: cma_agent
          release: mcafee
      properties:
        cma_agent:
          system_owner: "PIVOTAL"
          system_project: "CloudFoundry"
  ```

  If you decided to specify a download URL for the McAfee Agent for Linux instead of embedding it into the BOSH release, you must also add the `cma_agent.download_url` property:

  ```
  addons:
  ...
    properties:
      cma_agent:
        system_owner: "PIVOTAL"
        system_project: "CloudFoundry"
        download_url: "http://<MY CF APPS DOMAIN>/install.sh"
  ```

  Then run `bosh update runtime-config macafee.yml`. After you redeploy all your deployments, the McAfee Agent will be injected on all your VMs.

## Contributing

In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues](https://github.com/cf-platform-eng/mcafee-boshrelease/issues)
* by reviewing patches

### Submitting an Issue
We use the [GitHub issue tracker](https://github.com/cf-platform-eng/mcafee-boshrelease/issues) to track bugs and features. Before submitting a bug report or feature request, check to make sure it hasn't already been submitted. You can indicate support for an existing issue by voting it up. When submitting a bug report, please include a [Gist](http://gist.github.com/) that includes a stack trace and any details that may be necessary to reproduce the bug, including your gem version, Ruby version, and operating system. Ideally, a bug report should include a pull request with failing specs.

### Submitting a Pull Request

1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Commit and push your changes.
5. Submit a pull request.

## Copyright

Copyright (c) 2015-2016 Pivotal Software, Inc. See [LICENSE](https://github.com/cf-platform-eng/mcafee-boshrelease/blob/master/LICENSE) for details.
