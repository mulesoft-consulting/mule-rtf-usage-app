# MuleSoft Runtime Fabric Usage API

```
This application is still in pre-release status.
```

*An API that exposes usage information about an Anypoint Runtime Fabric cluster, specifically node and pod data.*

## About


This API and application is provided to allow the extraction of Runtime Fabric usage data - specifically millicores and memory allocated to deployed MuleSoft applications. This data can be helpful for operational management of a Runtime Fabric cluster, to highlight or alert on limits or capacity at a commercial or technical level.

It is envisaged that most customers will leverage this API to import data into a wider operational management toolset where it will be grouped and collated according to requirements, or to drive operational reports.

### IMPORTANT

_**This application is not a core part of the MuleSoft API Platform and as such is not warranted nor supported by MuleSoft. It is is provided as an "accelerator" to help existing customers with their day-to-day operations of the Anypoint Platform. MuleSoft Support engineers will not be able to assist with this tool via a Support case. If you require help with using or adapting this application, please speak with your Customer Success representative to engage with MuleSoft Professional Services.**_

_**Furthermore, no guarantees are made as to the function of this application and customers should review this to ensure it meets their needs prior to use. Specifically, whilst the application is believed functional at the time of release, no guarantees can be made regarding ongoing compatibility with future release of Anypoint Runtime Fabric or its underlying components.**_


## Usage

The API is deployed into the Runtime Fabric cluster that you wish to monitor. It will report on all MuleSoft applications deployed in that cluster, regardless of the Anypoint Business Group or environment that they are assocaited with.

The API exposes two resources.

### Nodes `GET /api/nodes`

This endpoint returns a list of all **worker nodes** that are present in the cluster, along with their maximum available CPU and memory capacity.

Example response:
```
[
    {
        "name": "10.0.0.1",
        "node_ip": "10.0.0.1",
        "cpu_millis": 2000,
        "memory_mb": 15633.0
    },
    {
        "name": "10.0.0.2",
        "node_ip": "10.0.0.2",
        "cpu_millis": 2000,
        "memory_mb": 15633.0
    }
]
```

### Pods `GET /api/pods`

This endpoint returns a list of all MuleSoft **application pods** or **replicas** that are deployed in the Fabric. It excludes RTF system pods and also any pod that is not marked in a 'ready' state.

Example response:
```
[
    {
        "name": "rtf-stats-79549b64f7-5fgqt",
        "application": "rtf-stats",
        "business_group_id": "12345678-abcd-abcd-abcd-1234567890",
        "environment_id": "12345678-abcd-abcd-abcd-1234567890",
        "status": "Running",
        "started_time": "2021-03-18T12:39:19Z",
        "uptime_mins": 8,
        "cpu_millis": {
            "requests": 200,
            "limits": 550
        },
        "memory_mb": {
            "requests": 1050,
            "limits": 1070
        },
        "node_ip": "10.0.0.1"
    },
    {
        "name": "demo-app-1-75346b3414-5dgxt",
        "application": "demo-app",
        "business_group_id": "12345678-abcd-abcd-abcd-1234567890",
        "environment_id": "12345678-abcd-abcd-abcd-1234567890",
        "status": "Running",
        "started_time": "2021-03-18T12:39:19Z",
        "uptime_mins": 8,
        "cpu_millis": {
            "requests": 200,
            "limits": 550
        },
        "memory_mb": {
            "requests": 1050,
            "limits": 1070
        },
        "node_ip": "10.0.0.1"
    }
]
```

## Installation

Please follow the steps below to install the application in your environment.

### Pre-requisites

- Download the code for the application to your local machine.

- Identify the Anypoint Environment that you wish to deploy the usage application into. This environment must be associated with your Runtime Fabric. Obtain the `Environment ID`, `Client ID` and `Client Secret` for this environment.


### Kubernetes configuration

**You will need console access (including root/sudo) to a controller node in your RTF cluster to perform these steps.**

1) Before installing the usage application, you need to configure your Kubernetes environment with some additional objects.
These include:
 - A ServiceAccount for the application to use.
 - A ClusterRole with permissions to read Kubernetes `node` and `pod` information.
 - A ClusterRoleBinding to associate the ClusterRole to your ServiceAccount.

2) Navigate to the folder in your RTF installation that contains the `rtfctl` tool (typically `/opt/anypoint/runtimefabric`).

3) Create or copy the file `prepare_k8s.sh` from `k8s_setup` in the downloaded application folder.

4) Make the script file executable (`chmod u+x prepare_k8s.sh`).

5) Run the script (`./prepare_k8s.sh`); you will need to provide your Anypoint `Environment ID` when prompted.

This will create the additional Kubernetes objects and store the secret for your new ServiceAccount as a secure property in RTF.

Repeat this step in each Runtime Fabric that you have. You do not need to repeat it for each Anypoint Environment that is associated with that fabric.

### Import into Anypoint Exchange

Once you have configured the Kubernetes environment, you need to prepare Anypoint Environment with the API configuration.

First import the API into your Anypoint Exchange.

1) Log in to Anypoint Platform, select the appropriate business group if applicable. Navigate to Anypoint Exchange.

2) Click **Publish new asset**. You will need to have `Exchange Contributor` role.

3) Enter the name of the asset: `MuleSoft RTF Usage API`; Asset types: `REST API - RAML`.

4) Open the upload dialog and browse to the RAML file in the downloaded application folder: `src/main/resources/api/mule-rtf-usage-api-v1.raml`.

5) Click **Publish**.

The RAML will be parsed and then loaded into your organization's Anypoint Exchange.


### Create managed API endpoint

With the API specification now in Anypoint Exchange, we can create the managed API endpoint in API Manager.

1) Log in to Anypoint Platform, select the appropriate business group if applicable. Navigate to API Manager and select the environment where the API will be hosted. This must match the environment for which you have the environment ID and credentials as above.

2) To create the API endpoint, click **Manage API** and **Manage API from Exchange**.

3) Select or type the name of the API (`MuleSoft RTF Usage API`); Application type as `Mule application`; Select Mule version as `Mule 4 or above`.

4) Once the API is created, make a note of the API Autodiscovery ID.

5) It is strongly recommended that the usage API is protected for use by authorized users and clients only. Add one or more policies to protect the API in accordance with your organization's security policies and capabilities. **Client ID Enforcement** is reccommended as a minimum; **JWT Token Enforcement** may also be used if supported by your clients. Speak with your Anypoint Platform administrators to determine the best policies to use.


### Deploy MuleSoft application

You are now ready to deploy the usage application into your Runtime Fabric cluster.

1) Log in to Anypoint Platform. select the appropriate business group if applicable. Navigate to Runtime Manager and select the environment where the application will be hosted. This must match the environment where you created the managed API endpoint above.

2) Click **Deploy application**.

3) Enter the application name, it is suggested to use `mule-rtf-usage-v1-<rtf_name>` where rtf_name is an identifier for your RTF cluster. This is useful if you have multiple RTF clusters. Select your RTF cluster as the Deployment Target, then click **Choose file** to browse to the downloaded application JAR file.

4) The Runtime version should be `4.3.0` (or above). The following additional settings are recommended but may be tuned according to your organization's needs or preferences.
  - Replicas: `1`
  - Deployment model: `Rolling update`
  - Reserved CPU: `0.2` vCPU
  - CPU limit: `0.5` vCPU
  - Memory: `1.0` GB

5) On **Ingress** ensure that **Enable inbound traffic** is selected and select an appropraite public endpoint from the dropdown. Last-mile security is not normally required but can be enabled if required - however this will require associated modifications to the Mule application to provide an HTTPS listener.

6) On **Properties** enter the following properties, using the values you have collected previously.
  - `api.id`: The Autodiscovery ID from the managed API endpoint
  - `anypoint.platform.client_id`: The client ID for the Anypoint environment
  - `anypoint.platform.client_secret`: The client secret for the Anypoint environment

7) Click **Deploy application** to upload the application JAR and deploy this to your Runtime Fabric cluster. This may take a few minutes.

8) Once the deployment is complete, you should be able to call your application using a test client, such as Postman or cURL. You may need to pass Authorization headers depending on your API policy configuration. If you are unable to connect, or get an error, please consult your application logs to ascertain the reason for the failure.

